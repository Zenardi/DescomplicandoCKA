### ✅ Gabarito: Exercícios Práticos CKA

#### Exercício 1: O Pod Imperativo

```bash
# 1. Gerar o manifesto com labels
kubectl run nginx-cka --image=nginx:1.19 --labels="env=prod" --dry-run=client -o yaml > pod1.yaml

# 2. Aplicar o manifesto
kubectl apply -f pod1.yaml

# 3. Desafio: Ver o Node sem describe (usando -o wide)
kubectl get po nginx-cka -o wide

```

#### Exercício 2: O Multi-container "Sidecar"

Como o `kubectl run` só cria um container por vez, o segredo aqui é usar o `dry-run` para criar a base e editar manualmente:

```bash
# 1. Gerar base
kubectl run multi-app --image=nginx --dry-run=client -o yaml > multi-app.yaml

# 2. Editar o arquivo multi-app.yaml e adicionar o segundo container na lista 'containers'
# (Adicione a seção do redis abaixo da do nginx)
# spec:
#   containers:
#   - image: nginx
#     name: multi-app
#   - image: redis
#     name: redis-sidecar

# 3. Aplicar
kubectl apply -f multi-app.yaml

```

#### Exercício 3: Sobrescrevendo Comandos

```bash
# 1. Gerar o YAML inicial
kubectl run busybox-quic --image=busybox --dry-run=client -o yaml -- /bin/sh -c "echo 'Kubernetes is awesome' && sleep 3600" > pod3.yaml

# O comando acima coloca tudo em 'args'. Para separar conforme o exercício:
# Edite o pod3.yaml:
# command: ["/bin/sh"]
# args: ["-c", "echo 'Kubernetes is awesome' && sleep 3600"]

# 2. Aplicar
kubectl apply -f pod3.yaml

```

#### Exercício 4: O "Fast Delete" (Troca de Imagem)

```bash
# 1. Salvar o estado atual
kubectl get po <nome-do-pod> -o yaml > pod-update.yaml

# 2. Editar a imagem no pod-update.yaml (Ex: de nginx:1.14 para nginx:1.21)

# 3. Substituição ultra-rápida (padrão CKA)
kubectl replace -f pod-update.yaml --force --grace-period=0

```

#### Exercício 5: Investigação (Troubleshooting)

```bash
# 1. Criar o pod com erro proposital
kubectl run pod-erro --image=nginx:9999

# 2. Investigar os eventos (procure por 'Failed' ou 'ErrImagePull')
kubectl describe po pod-erro

# 3. Consultar a documentação do campo de pull policy
kubectl explain pod.spec.containers.imagePullPolicy

```

---

### 💡 Dica Extra de Performance

Durante a prova, se você precisar deletar um pod para recriá-lo e não quiser esperar os 30 segundos padrão de "grace period", use este atalho:

```bash
export now="--force --grace-period=0"
kubectl delete po <nome> $now

```
