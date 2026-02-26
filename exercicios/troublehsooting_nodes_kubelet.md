No dia a dia da operação de clusters, o troubleshooting de Kubelet é mato. No exame CKA, essa é uma das partes que mais exige fluência em Linux e `systemd`, já que o Kubelet geralmente roda como um serviço direto no sistema operacional hospedeiro, servindo como a "ponte" entre o Control Plane e o Container Runtime do nó.

Aqui estão os cenários clássicos de falha de nós que você precisa dominar para a prova, focados na investigação imperativa.

Para estes exercícios, assuma que você tem um cluster com um nó control plane (`controlplane`) e dois nós workers (`worker-1` e `worker-2`).

### 💥 Parte 3: Troubleshooting de Nodes e Kubelet

**Exercícios:**

**58.** O nó `worker-1` está com o status `NotReady`. Investigue o motivo diretamente no nó, corrija o problema e garanta que o serviço problemático inicie automaticamente caso o nó seja reiniciado no futuro.
**59.** O nó `worker-2` também falhou e está `NotReady`. Ao tentar iniciar o serviço responsável, ele falha continuamente. Investigue os logs do sistema, identifique o erro de configuração (assuma que há um erro de digitação no caminho do arquivo de configuração) e recupere o nó.
**60.** Crie um **Static Pod** com a imagem `nginx` e o nome `static-web` rodando no nó `controlplane`. Você não deve usar a API do Kubernetes (`kubectl apply`) para criar este pod de forma persistente.

---

### 🛠️ Soluções - Parte 3

Na prova do CKA, você precisará fazer `ssh` para dentro dos nós problemáticos e usar ferramentas do Linux para diagnosticar.

**58. Serviço Kubelet parado ou desabilitado:**

O fluxo padrão de investigação de um nó `NotReady` começa verificando o status do `kubelet`.

1. Verifique o status geral:

```sh
kubectl get nodes

```

2. Acesse o nó problemático:

```sh
ssh worker-1

```

3. Verifique o status do Kubelet e inicie-o:

```sh
sudo systemctl status kubelet
sudo systemctl start kubelet

```

4. **Pegadinha de Exame:** A questão exige que ele inicie automaticamente no boot. Muitas vezes o candidato esquece o `enable`:

```sh
sudo systemctl enable kubelet

```

5. Saia do nó (`exit`) e valide com `kubectl get nodes` se ele voltou para `Ready`.

**59. Erro de configuração no Kubelet (Troubleshooting com Journalctl):**

Se o `kubelet` não inicia, o `journalctl` é a única forma de descobrir o porquê.

1. Acesse o nó:

```sh
ssh worker-2

```

2. Tente iniciar e veja que falha. Olhe os logs:

```sh
sudo systemctl restart kubelet
sudo journalctl -u kubelet -f

```

3. Nos logs, procure por erros relacionados a arquivos não encontrados (ex: `failed to load Kubelet config file /var/lib/kubelet/confg.yaml`). Perceba o erro de digitação (`confg.yaml` em vez de `config.yaml`).
4. Descubra onde o Kubelet está puxando essa configuração errada. O Kubelet lê o seu arquivo de serviço do systemd:

```sh
# Verifique o arquivo drop-in do kubeadm
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

```

5. Edite o arquivo `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` (ou o `/var/lib/kubelet/kubeadm-flags.env` dependendo de onde o erro foi injetado pela prova) e corrija o caminho para `/var/lib/kubelet/config.yaml`.
6. Aplique a alteração no systemd e reinicie o serviço:

```sh
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet

```

**60. Static Pods:**

Static Pods são gerenciados diretamente pelo Kubelet do nó, sem passar pelo `kube-apiserver` inicial. O Kubelet simplesmente monitora um diretório no disco e cria pods baseados nos manifestos YAML que são colocados lá.

1. Faça SSH no nó solicitado (neste caso, o control plane):

```sh
ssh controlplane

```

2. Descubra qual é o diretório de Static Pods. Para isso, olhe a configuração do Kubelet:

```sh
ps -aux | grep kubelet
# Procure pelo argumento --config=... (Geralmente é /var/lib/kubelet/config.yaml)
grep staticPodPath /var/lib/kubelet/config.yaml

```

*(Na imensa maioria dos clusters instalados com `kubeadm`, o caminho é `/etc/kubernetes/manifests`)*.
3. Gere o YAML do pod diretamente dentro desse diretório:

```sh
kubectl run static-web --image=nginx --dry-run=client -o yaml > /etc/kubernetes/manifests/static-web.yaml

```

4. O Kubelet detectará o arquivo e criará o pod imediatamente. Se você rodar `kubectl get pods -A` no seu terminal principal, verá o pod rodando com o nome `static-web-controlplane`.

---

