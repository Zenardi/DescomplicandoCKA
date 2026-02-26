No Kubernetes, o armazenamento é intencionalmente desacoplado dos Pods para garantir que os dados sobrevivam à efemeridade dos containers. Para o exame, você precisa dominar a criação e o vínculo (Binding) entre **PersistentVolumes (PV)**, **PersistentVolumeClaims (PVC)** e a utilização de **StorageClasses (SC)**.

Diferente de Deployments e Pods, recursos de Storage (PVs e StorageClasses) não possuem comandos `kubectl create` imperativos completos. Você precisará escrever ou copiar a estrutura YAML da documentação oficial durante a prova.

---

### 💾 Parte 6: Storage (PV, PVC e StorageClasses)

**Exercícios:**

**71.** Crie um **PersistentVolume** chamado `pv-data` com capacidade de `1Gi`, modo de acesso `ReadWriteOnce`, utilizando um `hostPath` no diretório `/mnt/data` do nó. Defina o `storageClassName` como `manual`.
**72.** Crie um **PersistentVolumeClaim** chamado `pvc-data` solicitando `500Mi` de armazenamento, com o modo de acesso `ReadWriteOnce` e apontando para o `storageClassName` `manual`.
**73.** Verifique o status do PV e do PVC criados. O objetivo é confirmar se o Kube-controller-manager realizou o *Bound* (vínculo) entre eles.
**74.** Crie um Pod chamado `pod-storage` utilizando a imagem `nginx`. Este pod deve montar o PVC `pvc-data` criado no exercício 72 no caminho `/usr/share/nginx/html` dentro do container.
**75.** Crie uma **StorageClass** chamada `fast-storage`. Utilize o provisionador `kubernetes.io/no-provisioner` e defina o `volumeBindingMode` como `WaitForFirstConsumer`.

---

### 🛠️ Soluções - Parte 6

**71. Criar o PersistentVolume (PV):**
Na prova, use a busca da documentação oficial (kubernetes.io/docs) procurando por "Persistent Volume" para copiar o template base rapidamente.
Crie o arquivo `pv-data.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /mnt/data

```

Aplique com: `kubectl apply -f pv-data.yaml`

**72. Criar o PersistentVolumeClaim (PVC):**
O PVC atua como o "pedido" de armazenamento do usuário. O Kubernetes vai procurar um PV que satisfaça (ou exceda) esse pedido e que tenha a mesma `StorageClass`.
Crie o arquivo `pvc-data.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi

```

Aplique com: `kubectl apply -f pvc-data.yaml`

**73. Verificar o Status do Binding:**

```sh
kubectl get pv,pvc

```

*Dica de Exame:* Na saída deste comando, o status de ambos deve ser **`Bound`**. Se estiver como `Pending`, verifique se você digitou o `storageClassName` ou o `accessModes` exatamente iguais em ambos os arquivos. O Kubernetes é case-sensitive.

**74. Pod montando o PVC:**
Você pode gerar o esqueleto do pod com `kubectl run pod-storage --image=nginx $do > pod-storage.yaml` e depois adicionar as seções `volumes` e `volumeMounts`.

O arquivo final `pod-storage.yaml` ficará assim:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-storage
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: meu-armazenamento
  volumes:
  - name: meu-armazenamento
    persistentVolumeClaim:
      claimName: pvc-data

```

Aplique com: `kubectl apply -f pod-storage.yaml`

**75. Criar uma StorageClass:**
StorageClasses são vitais para o provisionamento dinâmico (onde o PV é criado automaticamente na nuvem, como um disco EBS na AWS). O modo `WaitForFirstConsumer` atrasa o binding do PVC até que um Pod que o utilize seja efetivamente agendado em um nó.

Crie o arquivo `sc-fast.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

```

Aplique com: `kubectl apply -f sc-fast.yaml`

---
