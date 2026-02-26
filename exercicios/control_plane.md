O Control Plane é o "cérebro" do cluster e o foco principal de troubleshooting pesado, especialmente no exame CKA (no CKAD você não gerencia o Control Plane).

Quando o Control Plane falha, o `kubectl` geralmente para de responder, o que significa que você perde sua ferramenta principal de diagnóstico e precisa recorrer ao acesso via SSH no nó master (controlplane) e inspecionar os logs diretamente no Container Runtime (containerd/crictl) ou no diretório de Static Pods.

Aqui estão os cenários clássicos de quebra e recuperação do Control Plane.

---

### 🧠 Parte 4: Troubleshooting de Control Plane e ETCD

Para estes exercícios, assuma que você está conectado no nó `controlplane` via SSH e possui privilégios de root (`sudo -i`). O cluster foi provisionado com `kubeadm`.

**Exercícios:**

**61.** O cluster parou de responder a qualquer comando (ex: `The connection to the server <ip>:6443 was refused`). Investigue o control plane, identifique o motivo de o `kube-apiserver` não estar rodando e corrija o problema (assuma que alguém alterou incorretamente o arquivo de configuração e quebrou a porta de comunicação do serviço).
**62.** Realize um backup (snapshot) do banco de dados `etcd` do cluster e salve no arquivo `/opt/etcd-backup.db`. Utilize os certificados localizados em `/etc/kubernetes/pki/etcd/`.
**63.** Restaure o snapshot do `etcd` criado no exercício anterior para um novo diretório de dados chamado `/var/lib/etcd-restored`.
**64.** Após restaurar o snapshot no diretório `/var/lib/etcd-restored`, reconfigure o cluster para utilizar este novo banco de dados em vez do original, garantindo que o `etcd` suba com os dados recuperados.
**65.** Você notou que pods recém-criados ficam travados no estado `Pending` indefinidamente, mesmo com recursos sobrando nos workers. Investigue o Control Plane, descubra qual componente falhou (assuma um erro de digitação no nome da imagem do `kube-scheduler`) e restabeleça o agendamento padrão.

---

### 🛠️ Soluções - Parte 4

**61. Kube-Apiserver quebrado (The connection was refused):**

Se a API não responde, você não pode usar `kubectl logs`. Você precisa ir na "raiz" do problema.

1. Acesse o diretório de Static Pods do kubeadm, que é quem gerencia o Control Plane:

```sh
cd /etc/kubernetes/manifests/

```

2. Verifique se há erros no manifesto do `kube-apiserver.yaml`. Como a dica mencionou a porta, abra o arquivo:

```sh
cat kube-apiserver.yaml | grep secure-port

```

3. Se você notar que a porta está errada (ex: `--secure-port=6444` em vez de `6443`), edite o arquivo usando `vi` ou `nano`.

```sh
vi kube-apiserver.yaml
# Altere para: - --secure-port=6443

```

4. Salve o arquivo. O `kubelet` que roda no nó master vai detectar a mudança no arquivo e reiniciar o pod do `kube-apiserver` automaticamente. Aguarde cerca de 1 a 2 minutos e teste novamente com `kubectl get nodes`.

*(Dica de SRE: Se a alteração não for óbvia no YAML, você pode procurar os logs do container falho usando o runtime do nó: `crictl ps -a | grep kube-apiserver` e depois `crictl logs <container-id>`)*.

**62. Backup do ETCD (Snapshot):**

Esta é uma questão **garantida** no CKA. Você precisa usar a ferramenta `etcdctl` passando os certificados de autenticação (CACert, Certificado do Servidor e Chave Privada).

```sh
# É mandatório exportar a variável da API v3 antes de rodar o comando no K8s moderno
export ETCDCTL_API=3

etcdctl snapshot save /opt/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

```

Verifique se o backup foi criado com sucesso: `etcdctl snapshot status /opt/etcd-backup.db -w table`

**63. Restore do ETCD para um novo diretório:**

O restore não substitui os dados em uso diretamente para evitar corrupção. Você restaura para uma *nova* pasta e depois aponta o pod para lá.

```sh
export ETCDCTL_API=3

etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored

```

*(Importante: O comando restore **não** precisa dos certificados, pois ele atua apenas sobre o arquivo local e o sistema de arquivos, e não fazendo chamadas de rede para o serviço do etcd).*

**64. Reconfigurando o pod do ETCD para usar o novo banco:**

Agora você precisa dizer ao Static Pod do ETCD para parar de olhar para a pasta antiga (`/var/lib/etcd`) e olhar para a nova (`/var/lib/etcd-restored`).

1. Edite o manifesto do etcd:

```sh
vi /etc/kubernetes/manifests/etcd.yaml

```

2. Vá até o final do arquivo, na seção `volumes`. Encontre o volume `etcd-data` e mude o `hostPath` para o diretório restaurado:

```yaml
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd-restored  # <--- ALTERE AQUI
      type: DirectoryOrCreate
    name: etcd-data

```

3. Salve o arquivo. O kubelet vai reiniciar o pod do ETCD. Aguarde um instante e a API voltará a responder com os dados restaurados do backup.

**65. Troubleshooting do Kube-Scheduler (Pods Pending):**

Se os pods ficam em `Pending` e não há falta de CPU/Memória, o responsável por alocar os pods nos nós (Scheduler) está inoperante.

1. Tente listar os pods do system `kube-system` (se a API estiver de pé):

```sh
kubectl get pods -n kube-system

```

2. Se você notar o `kube-scheduler` em `ImagePullBackOff` ou `ErrImagePull`, o problema é a imagem.
3. Vá para os manifestos estáticos:

```sh
cd /etc/kubernetes/manifests/
vi kube-scheduler.yaml

```

4. Verifique a linha `image:`. Corrija qualquer erro de digitação (ex: de `k8s.gcr.io/kube-schedulerr:v1.28.0` para `registry.k8s.io/kube-scheduler:v1.28.0`).
5. Salve e saia. O kubelet reiniciará o scheduler e seus pods em `Pending` mudarão para `ContainerCreating` e `Running`.

---
