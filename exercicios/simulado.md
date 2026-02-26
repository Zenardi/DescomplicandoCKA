# ⏱️ Simulado K8s: O Desafio Final (60 Minutos)

**Regras do Jogo:**

* Você tem **60 minutos** para concluir as 8 tarefas abaixo.
* Tente resolver usando apenas a linha de comando (`kubectl`) e edição rápida de YAML. Evite escrever manifestos longos do zero.
* Assuma que você está em um cluster padrão com um nó `controlplane` e dois workers (`worker-1` e `worker-2`).
* Se travar em uma questão, pule e volte depois. O gerenciamento de tempo é crucial.

### 📝 Cenário Prático

**Tarefa 1: Preparação e RBAC (Peso 10%)**

1. Crie um namespace chamado `cka-simulado`.
2. Dentro deste namespace, crie uma `ServiceAccount` chamada `app-admin`.
3. Crie uma `Role` chamada `app-role` que permita criar, listar e deletar `deployments` e `pods`.
4. Crie um `RoleBinding` chamado `app-binding` vinculando a `app-role` à `app-admin`.

**Tarefa 2: Configuração (Peso 10%)**

1. Crie um `ConfigMap` chamado `simulado-cm` no namespace `cka-simulado` com a chave `ENV_MODE` e o valor `production`.

**Tarefa 3: Workloads e Injeção (Peso 20%)**

1. Crie um `Deployment` chamado `frontend-deploy` no namespace `cka-simulado`.
2. O deployment deve ter **3 réplicas** e usar a imagem `nginx:alpine`.
3. Configure o deployment para usar a `ServiceAccount` `app-admin` (criada na Tarefa 1).
4. Injete o `ConfigMap` `simulado-cm` como variáveis de ambiente em todos os containers deste deployment.

**Tarefa 4: Exposição e Ingress (Peso 15%)**

1. Exponha o `frontend-deploy` internamente no cluster através de um `Service` chamado `frontend-svc` na porta `80`.
2. Crie um recurso de `Ingress` chamado `frontend-ingress` no namespace `cka-simulado`.
3. Configure o Ingress para direcionar todo o tráfego do host `simulado.k8s.local` no caminho `/` para o `frontend-svc` na porta `80`.

**Tarefa 5: Segurança de Rede (Peso 15%)**

1. Crie uma `NetworkPolicy` chamada `frontend-netpol` no namespace `cka-simulado`.
2. A política deve ser aplicada aos pods do `frontend-deploy`.
3. Ela deve permitir tráfego de entrada (Ingress) na porta `80` **apenas** de pods que possuam a label `role=ingress-controller` em qualquer namespace.
4. Todo o resto do tráfego de entrada para o `frontend-deploy` deve ser bloqueado.

**Tarefa 6: Storage Consistente (Peso 10%)**

1. Crie um `PersistentVolumeClaim` (PVC) chamado `app-data-pvc` no namespace `cka-simulado` solicitando `2Gi` de armazenamento com o modo `ReadWriteOnce`. (Assuma que já existe uma StorageClass padrão no cluster).
2. Edite o `frontend-deploy` (da Tarefa 3) e monte este PVC no caminho `/var/www/html` dentro dos containers nginx.

**Tarefa 7: Taints e Tolerations (Peso 10%)**

1. Assuma que o nó `worker-1` possui o seguinte taint: `node-role.kubernetes.io/database=true:NoSchedule`.
2. Crie um Pod isolado chamado `db-pod` no namespace `cka-simulado` usando a imagem `redis`.
3. Adicione uma *Toleration* a este pod para que ele seja capaz de ser agendado no `worker-1`, ignorando o taint acima.

**Tarefa 8: Backup do Control Plane (Peso 10%)**

1. Realize um backup do banco de dados ETCD do cluster.
2. Salve o arquivo de snapshot no caminho `/opt/backup/etcd-simulado.db`.
3. Os certificados do ETCD estão localizados no diretório padrão do kubeadm (`/etc/kubernetes/pki/etcd/`).

---

# Gabarito

> [!TIP]
> Sempre que possível, utilize a abordagem imperativa (`kubectl create`, `set`, `expose`), que é a melhor estratégia para poupar tempo e garantir a aprovação.

---

### ✅ Tarefa 1: Preparação e RBAC

```sh
# 1. Criar o namespace
kubectl create namespace cka-simulado

# 2. Criar a ServiceAccount
kubectl create serviceaccount app-admin -n cka-simulado

# 3. Criar a Role
kubectl create role app-role \
  --verb=create,list,delete \
  --resource=deployments,pods \
  -n cka-simulado

# 4. Criar o RoleBinding
kubectl create rolebinding app-binding \
  --role=app-role \
  --serviceaccount=cka-simulado:app-admin \
  -n cka-simulado

```

---

### ✅ Tarefa 2: Configuração

```sh
kubectl create configmap simulado-cm \
  --from-literal=ENV_MODE=production \
  -n cka-simulado

```

---

### ✅ Tarefa 3: Workloads e Injeção

```sh
# 1 e 2. Criar o Deployment com a imagem e réplicas corretas
kubectl create deployment frontend-deploy \
  --image=nginx:alpine \
  --replicas=3 \
  -n cka-simulado

# 3. Associar a ServiceAccount ao Deployment
kubectl set serviceaccount deployment/frontend-deploy app-admin -n cka-simulado

# 4. Injetar o ConfigMap inteiro como variáveis de ambiente
kubectl set env deployment/frontend-deploy \
  --from=configmap/simulado-cm \
  -n cka-simulado

```

---

### ✅ Tarefa 4: Exposição e Ingress

```sh
# 1. Expor o Deployment com um Service
kubectl expose deployment frontend-deploy \
  --name=frontend-svc \
  --port=80 \
  --target-port=80 \
  -n cka-simulado

# 2 e 3. Criar o Ingress com o host e path especificados
kubectl create ingress frontend-ingress \
  --rule="simulado.k8s.local/=frontend-svc:80" \
  -n cka-simulado

```

---

### ✅ Tarefa 5: Segurança de Rede

Como o deployment foi criado de forma imperativa, ele automaticamente ganha a label `app=frontend-deploy`. Usaremos isso no `podSelector`. Para permitir tráfego de *qualquer* namespace contanto que o pod tenha uma label específica, usamos o `namespaceSelector: {}` em conjunto com o `podSelector`.

Crie o arquivo `netpol.yaml` e aplique (`kubectl apply -f netpol.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-netpol
  namespace: cka-simulado
spec:
  podSelector:
    matchLabels:
      app: frontend-deploy
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector: {} # Omitir a label de namespace permite "qualquer namespace"
      podSelector:
        matchLabels:
          role: ingress-controller
    ports:
    - protocol: TCP
      port: 80

```

---

### ✅ Tarefa 6: Storage Consistente

**1. Criar o PVC:**
Crie o arquivo `pvc.yaml` e aplique (`kubectl apply -f pvc.yaml`):

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
  namespace: cka-simulado
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

**2. Montar o PVC no Deployment existente (Forma imperativa):**

```sh
kubectl set volume deployment/frontend-deploy \
  --add \
  --name=app-volume \
  --type=pvc \
  --claim-name=app-data-pvc \
  --mount-path=/var/www/html \
  -n cka-simulado

```

---

### ✅ Tarefa 7: Taints e Tolerations

Primeiro, gere o esqueleto do Pod:

```sh
kubectl run db-pod --image=redis -n cka-simulado --dry-run=client -o yaml > db-pod.yaml

```

Edite o arquivo `db-pod.yaml` adicionando o bloco `tolerations` no nível da `spec`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: db-pod
  name: db-pod
  namespace: cka-simulado
spec:
  containers:
  - image: redis
    name: db-pod
  tolerations:
  - key: "node-role.kubernetes.io/database"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

```

Aplique com `kubectl apply -f db-pod.yaml`.

---

### ✅ Tarefa 8: Backup do Control Plane

Lembre-se de sempre definir a variável `ETCDCTL_API=3` (alguns ambientes de prova já a trazem configurada, mas é bom garantir). O backup deve ser rodado no nó control plane (ou onde o etcd estiver acessível).

```sh
export ETCDCTL_API=3

# Garantir que o diretório de destino existe
mkdir -p /opt/backup/

etcdctl snapshot save /opt/backup/etcd-simulado.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

```

---

