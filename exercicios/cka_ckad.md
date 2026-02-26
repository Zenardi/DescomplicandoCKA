# Exercícios CKA e CKAD

- [Exercícios CKA e CKAD](#exerc-cios-cka-e-ckad)
- [Soluções](#solu--es)
    + [🟢 Gestão de Pods (Exercícios 1 a 16)](#---gest-o-de-pods--exerc-cios-1-a-16-)
    + [🔵 Deployments e ReplicaSets (Exercícios 17 a 31)](#---deployments-e-replicasets--exerc-cios-17-a-31-)
    + [🟡 ConfigMaps (Exercícios 32 a 42)](#---configmaps--exerc-cios-32-a-42-)
    + [🟣 Secrets (Exercícios 43 a 52)](#---secrets--exerc-cios-43-a-52-)

**1.** Crie um POD com as seguintes características utilizando `kubectl`:

* **nome:** `ex-1`
* **image:** `nginx`
* **port:** `80`

**2.** Crie um POD com as seguintes características utilizando `yaml`:

* **nome:** `ex-2`
* **image:** `nginx:latest`
* **port:** `80`

**3.** Crie um POD com as seguintes características:

* **nome:** `ex-3`
* **container 1:**
* **image:** `nginx`
* **port:** `80`


* **container 2:**
* **image:** `redis`
* **port:** `6379`



**4.** Liste o nome de todos os pods no namespace `default`.

**5.** Liste o nome de todos os pods no namespace `default` e salve os nomes no arquivo `/tmp/pods`.

**6.** Utilizando o pod criado no exercício 3, faça um teste de conexão entre os containers `nginx` e `redis`.

**7.** Obtenha todos os detalhes do pod criado no exercício 1 e também direcione a saída do comando para o arquivo `/tmp/pod1`.

**8.** Delete o pod criado no exercício 1.

**9.** Delete o pod criado no exercício 3 sem nenhum delay.

**10.** Altere a imagem do pod criado no exercício 2 para `nginx:alpine`.

**11.** Obtenha a versão da imagem do container do CoreDNS localizado no namespace `kube-system` e salve em `/tmp/core-image`.

**12.** Crie um POD com as seguintes características:

* **nome:** `ex-12`
* **image:** `nginx`
* **port:** `80`
* *Após isso, obtenha todas as variáveis de ambiente desse container e salve em `/tmp/env-12`.*

**13.** Crie um POD com as seguintes características:

* **nome:** `ex-13`
* **image:** `nginx`
* **port:** `80`
* **env:** `tier=web`
* **env:** `environment=dev`
* *Após isso, obtenha todas as variáveis de ambiente desse container e salve em `/tmp/env-13`.*

**14.** Crie um POD com as seguintes características:

* **nome:** `ex-14`
* **image:** `busybox`
* **args:** `sleep 3600`
* *Obtenha todas as variáveis de ambiente desse container e salve em `/tmp/env-14`.*

**15.** Crie um POD com as seguintes características:

* **nome:** `ex-15`
* **image:** `busybox`
* **args:** `sleep 3600`
* *Após isso, acesse o shell desse container e execute o comando `id`.*

**16.** Delete todos os pods no namespace `default`.

**17.** Crie um Deployment com as seguintes características:

* **nome:** `deploy-1`
* **image:** `nginx`
* **port:** `80`
* **replicas:** `1`

**18.** Consulte o status do Deployment criado anteriormente.

**19.** Altere a image do deployment para `nginx:alpine`.

**20.** Consulte todos os ReplicaSets criados por esse deployment.

**21.** Altere a image do deployment para `nginx:latest` e adicione um motivo de causa (record).

**22.** Agora volte esse deployment para a "revision 1".

**23.** Verifique qual imagem o deployment está utilizando e grave em `/tmp/deploy-image`.

**24.** Escale esse deployment para 5 replicas utilizando o `kubectl`.

**25.** Escale esse deployment para 2 replicas utilizando o `kubectl edit`.

**26.** Pause o deployment.

**27.** Altere a image do deployment para `nginx:alpine`.

**28.** Agora tire o pause deste deployment.

**29.** Verifique qual imagem o deployment está utilizando e grave em `/tmp/deploy-image-pause`.

**30.** Crie um Deployment com as seguintes características utilizando um `yaml`:

* **nome:** `deploy-30`
* **replicas:** `5`
* **container 1:**
* **name:** `web`
* **image:** `nginx`
* **port:** `80`
* **env:** `tier=web`
* **env:** `environment=prod`


* **container 2:**
* **nome:** `sleep`
* **image:** `busybox`
* **command:** `sleep 3600`



**31.** Delete todos os deployments no namespace `default`.

**32.** Crie um ConfigMap com as seguintes características utilizando um `yaml`:

* **nome:** `env-configs`
* **IP:** `10.0.0.1`
* **SERVER:** `nginx`

**33.** Verifique o ConfigMap criado.

**34.** Obtenha todos os dados do ConfigMap criado para `/tmp/configmap`.

**35.** Crie um ConfigMap com as seguintes características utilizando o `kubectl`:

* **nome:** `env-configs-kubectl`
* **tier:** `web`
* **server:** `homolog`

**36.** Crie um POD com as seguintes características:

* **nome:** `ex-cm-pod1`
* **image:** `nginx`
* **port:** `80`
* *Agora monte o configMap `env-configs-kubectl` como volume em `/data`.*

**37.** Altere o pod `ex-cm-pod1`, agora montando somente o item `tier` com o nome `ambiente.conf` em `/data`.

**38.** Altere o pod `ex-cm-pod1`, remova todos os volumes e exporte o configMap completo como variáveis de ambiente. Após isso, execute o comando `env`.

**39.** Altere o pod `ex-cm-pod1`, agora exporte somente o valor do item `server` para a variável `ENVIRONMENT`. Após isso, execute o comando `env`.

**40.** Altere o configMap `env-configs-kubectl`, mude o valor de `server` para `prod` e faça essa alteração refletir no pod criado anteriormente.

**41.** Altere o configMap `env-configs-kubectl` para imutável.

**42.** Delete todos os pods e configmaps criados anteriormente.

**43.** Crie uma Secret com as seguintes características utilizando um `yaml`:

* **nome:** `user-secret`
* **user:** `superadmin`
* **pass:** `minhasenhasupersegura`

**44.** Verifique a Secret criada.

**45.** Obtenha os dados da Secret criada para `/tmp/secret` e descriptografe seus valores em `/tmp/decrypt`.

**46.** Crie uma Secret com as seguintes características utilizando o `kubectl`:

* **nome:** `user-secret-kubectl`
* **user:** `newuser`
* **pass:** `agoraeseguraem`

**47.** Crie um POD com as seguintes características:

* **nome:** `ex-secret-pod1`
* **image:** `nginx`
* **port:** `80`
* *Agora monte a secret `user-secret-kubectl` como volume em `/secret`.*

**48.** Altere o pod `ex-secret-pod1`, montando somente o item `user` agora com o nome `user.conf` em `/secret`.

**49.** Altere o pod `ex-secret-pod1`, remova todos os volumes e exporte a secret completa como variáveis de ambiente. Após isso, execute o comando `env`.

**50.** Altere o pod `ex-secret-pod1`, agora exporte somente o valor do item `pass` para a variável `SENHA`. Após isso, execute o comando `env`.

**51.** Altere a secret `user-secret-kubectl` e mude o valor de `pass` para `minhanovasenhasegura` e faça essa alteração refletir no pod criado anteriormente.

**52.** Altere a secret `user-secret-kubectl` para imutável.

---

# Soluções

Dominar a abordagem imperativa (`kubectl`) mesclada com a edição rápida de manifestos declarativos é a melhor estratégia para ganhar tempo nas provas CKA/CKAD e também agiliza bastante o troubleshooting no dia a dia operando clusters.

Para acelerar a execução destes exercícios (e no exame), recomendo configurar estas variáveis no seu terminal antes de começar:

```sh
alias k=kubectl
export do="--dry-run=client -o yaml"

```

Abaixo estão as soluções e manifestos para cada um dos desafios propostos.

---

### 🟢 Gestão de Pods (Exercícios 1 a 16)

**1. Criar Pod via kubectl:**

```sh
kubectl run ex-1 --image=nginx --port=80

```

**2. Criar Pod via yaml:**

```sh
# Gera o template rapidamente
kubectl run ex-2 --image=nginx:latest --port=80 $do > ex-2.yaml
kubectl apply -f ex-2.yaml

```

**3. Pod Multi-container:**
Crie um arquivo `ex-3.yaml` e aplique com `kubectl apply -f ex-3.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ex-3
spec:
  containers:
  - name: container-1
    image: nginx
    ports:
    - containerPort: 80
  - name: container-2
    image: redis
    ports:
    - containerPort: 6379

```

**4. Listar pods:**

```sh
kubectl get pods

```

**5. Listar e salvar nomes:**

```sh
kubectl get pods -o custom-columns=NAME:.metadata.name --no-headers > /tmp/pods

```

**6. Testar conexão entre containers no mesmo pod:**
Como compartilham o mesmo `network namespace`, eles se comunicam via `localhost`:

```sh
kubectl exec -it ex-3 -c container-1 -- curl localhost:6379

```

**7. Obter detalhes e salvar:**

```sh
kubectl describe pod ex-1 > /tmp/pod1

```

**8. Deletar pod:**

```sh
kubectl delete pod ex-1

```

**9. Deletar pod sem delay (Force delete):**

```sh
kubectl delete pod ex-3 --force --grace-period=0

```

**10. Alterar imagem do pod:**

```sh
kubectl set image pod/ex-2 ex-2=nginx:alpine

```

**11. Obter versão da imagem do CoreDNS:**

```sh
kubectl get pod -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[0].spec.containers[0].image}' > /tmp/core-image

```

**12. Criar pod e obter variáveis (padrão):**

```sh
kubectl run ex-12 --image=nginx --port=80
kubectl exec ex-12 -- env > /tmp/env-12

```

**13. Criar pod com ENV injetada:**

```sh
kubectl run ex-13 --image=nginx --port=80 --env="tier=web" --env="environment=dev"
kubectl exec ex-13 -- env > /tmp/env-13

```

**14. Executar command/args e ler variáveis:**

```sh
kubectl run ex-14 --image=busybox -- sleep 3600
kubectl exec ex-14 -- env > /tmp/env-14

```

**15. Acessar shell do container e rodar comando:**

```sh
kubectl run ex-15 --image=busybox -- sleep 3600
kubectl exec -it ex-15 -- sh
# Dentro do shell digite: id

```

**16. Limpar namespace:**

```sh
kubectl delete pods --all

```

---

### 🔵 Deployments e ReplicaSets (Exercícios 17 a 31)

**17. Criar Deployment:**

```sh
kubectl create deployment deploy-1 --image=nginx --replicas=1
# Obs: O kubectl create deployment não aceita a flag --port diretamente.
# Você pode expor a porta depois com 'kubectl expose' ou editar o yaml.

```

**18. Consultar status:**

```sh
kubectl rollout status deployment/deploy-1

```

**19. Alterar imagem:**

```sh
kubectl set image deployment/deploy-1 nginx=nginx:alpine

```

**20. Consultar ReplicaSets:**

```sh
kubectl get rs -l app=deploy-1

```

**21. Alterar imagem e gravar motivo (Record):**
*(Nota: A flag `--record` está sendo depreciada no K8s, mas ainda é comum em materiais de estudo)*

```sh
kubectl set image deployment/deploy-1 nginx=nginx:latest --record=true

```

**22. Rollback do Deployment:**

```sh
kubectl rollout undo deployment/deploy-1 --to-revision=1

```

**23. Verificar imagem atual:**

```sh
kubectl get deployment deploy-1 -o jsonpath='{.spec.template.spec.containers[0].image}' > /tmp/deploy-image

```

**24. Escalar via kubectl:**

```sh
kubectl scale deployment/deploy-1 --replicas=5

```

**25. Escalar via edit:**

```sh
kubectl edit deployment deploy-1
# Encontre 'replicas: 5' e mude para '2'. Salve e saia (:wq).

```

**26. Pausar Deployment:**

```sh
kubectl rollout pause deployment/deploy-1

```

**27. Alterar imagem (enquanto pausado):**

```sh
kubectl set image deployment/deploy-1 nginx=nginx:alpine

```

**28. Retomar (Resume) Deployment:**

```sh
kubectl rollout resume deployment/deploy-1

```

**29. Verificar imagem novamente:**

```sh
kubectl get deployment deploy-1 -o jsonpath='{.spec.template.spec.containers[0].image}' > /tmp/deploy-image-pause

```

**30. Deployment Multi-container via YAML:**
`deploy-30.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-30
spec:
  replicas: 5
  selector:
    matchLabels:
      app: deploy-30
  template:
    metadata:
      labels:
        app: deploy-30
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
        env:
        - name: tier
          value: web
        - name: environment
          value: prod
      - name: sleep
        image: busybox
        command: ["sleep", "3600"]

```

**31. Limpar deployments:**

```sh
kubectl delete deployments --all

```

---

### 🟡 ConfigMaps (Exercícios 32 a 42)

**32. Criar ConfigMap via YAML:**
`env-configs.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-configs
data:
  IP: "10.0.0.1"
  SERVER: "nginx"

```

**33. Verificar o ConfigMap:**

```sh
kubectl describe cm env-configs

```

**34. Exportar dados:**

```sh
kubectl get cm env-configs -o yaml > /tmp/configmap

```

**35. Criar ConfigMap via kubectl:**

```sh
kubectl create cm env-configs-kubectl --from-literal=tier=web --from-literal=server=homolog

```

**36. Pod montando CM como volume:**
`ex-cm-pod1.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ex-cm-pod1
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: config-vol
      mountPath: /data
  volumes:
  - name: config-vol
    configMap:
      name: env-configs-kubectl

```

**37. Montar apenas um item específico do CM:**
Altere a seção `volumes` e `volumeMounts` no yaml anterior:

```yaml
    volumeMounts:
    - name: config-vol
      mountPath: /data/ambiente.conf
      subPath: tier
# ...
  volumes:
  - name: config-vol
    configMap:
      name: env-configs-kubectl

```

**38. Exportar todo o CM como variáveis de ambiente:**
Remova a configuração de volume e use `envFrom`:

```yaml
#...
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: env-configs-kubectl

```

Após recriar o pod: `kubectl exec ex-cm-pod1 -- env`

**39. Exportar apenas um item do CM como variável específica:**

```yaml
#...
  containers:
  - name: nginx
    image: nginx
    env:
    - name: ENVIRONMENT
      valueFrom:
        configMapKeyRef:
          name: env-configs-kubectl
          key: server

```

Após recriar: `kubectl exec ex-cm-pod1 -- env`

**40. Editar valor e refletir no Pod:**

```sh
kubectl patch cm env-configs-kubectl -p '{"data":{"server":"prod"}}'

```

*(Importante: se o CM foi injetado como variável de ambiente (ex. 38/39), o pod precisa ser reiniciado para pegar o novo valor. Se montado como volume (ex. 36), o Kubelet atualiza o arquivo automaticamente em alguns minutos).*

**41. Tornar ConfigMap imutável:**

```sh
kubectl patch cm env-configs-kubectl -p '{"immutable":true}'

```

**42. Limpar recursos:**

```sh
kubectl delete pods,cm --all

```

---

### 🟣 Secrets (Exercícios 43 a 52)

**43. Criar Secret via YAML:**
*Nota: Valores no YAML de Secret precisam estar em base64 (`echo -n "superadmin" | base64`).*
`user-secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: user-secret
type: Opaque
data:
  user: c3VwZXJhZG1pbg== # superadmin
  pass: bWluaGFzZW5oYXN1cGVyc2VndXJh # minhasenhasupersegura

```

**44. Verificar Secret:**

```sh
kubectl describe secret user-secret

```

**45. Obter e descriptografar:**

```sh
kubectl get secret user-secret -o yaml > /tmp/secret
kubectl get secret user-secret -o jsonpath='{.data.pass}' | base64 --decode > /tmp/decrypt
kubectl get secret user-secret -o jsonpath='{.data.user}' | base64 --decode >> /tmp/decrypt

```

**46. Criar Secret via kubectl (Imperativo):**

```sh
kubectl create secret generic user-secret-kubectl --from-literal=user=newuser --from-literal=pass=agoraeseguraem

```

**47. Montar Secret como volume:**
`ex-secret-pod1.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ex-secret-pod1
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: secret-vol
      mountPath: /secret
  volumes:
  - name: secret-vol
    secret:
      secretName: user-secret-kubectl

```

**48. Montar item específico da Secret:**
Altere os volumes no yaml:

```yaml
    volumeMounts:
    - name: secret-vol
      mountPath: /secret/user.conf
      subPath: user
# ...
  volumes:
  - name: secret-vol
    secret:
      secretName: user-secret-kubectl

```

**49. Secret completa como Variáveis de Ambiente:**

```yaml
# ...
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - secretRef:
        name: user-secret-kubectl

```

Após aplicar: `kubectl exec ex-secret-pod1 -- env`

**50. Variável específica da Secret:**

```yaml
# ...
  containers:
  - name: nginx
    image: nginx
    env:
    - name: SENHA
      valueFrom:
        secretKeyRef:
          name: user-secret-kubectl
          key: pass

```

Após aplicar: `kubectl exec ex-secret-pod1 -- env`

**51. Alterar Secret:**
Como o `patch` pode ser chato com base64, recriar ou editar é mais simples:

```sh
kubectl create secret generic user-secret-kubectl --from-literal=user=newuser --from-literal=pass=minhanovasenhasegura --dry-run=client -o yaml | kubectl apply -f -

```

**52. Tornar Secret imutável:**

```sh
kubectl patch secret user-secret-kubectl -p '{"immutable":true}'

```




