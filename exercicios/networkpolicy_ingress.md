### 🛡️ Parte 1: NetworkPolicies (Segurança de Rede)

Para estes exercícios, vamos assumir que você tem os seguintes pods rodando no namespace `default`:

* Um pod com a label `app=frontend`
* Um pod com a label `app=backend`
* Um pod com a label `app=database`

**Exercícios:**
**53.** Crie uma NetworkPolicy chamada `default-deny-all` que bloqueie **todo** o tráfego de entrada (Ingress) e saída (Egress) no namespace `default`. (Esta é uma excelente prática de segurança).
**54.** Crie uma NetworkPolicy chamada `allow-front-to-back` que permita que o pod `frontend` acesse o pod `backend` na porta 8080.
**55.** Crie uma NetworkPolicy chamada `allow-namespace-prod` que permita que qualquer pod no namespace `prod` (que possui a label `env=prod`) acesse o pod `database` na porta 5432.

---

#### Soluções - Parte 1

**53. Default Deny All:**
Nesta política, deixamos as chaves `ingress` e `egress` vazias `[]`, o que significa que nada é permitido.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {} # Seleciona todos os pods no namespace
  policyTypes:
  - Ingress
  - Egress

```

**54. Allow Frontend to Backend:**
Lembre-se: a política é aplicada ao destino (`backend`), definindo quem pode entrar (`frontend`).

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front-to-back
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend # Aplica a regra no backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend # Permite tráfego vindo do frontend
    ports:
    - protocol: TCP
      port: 8080

```

**55. Allow tráfego de outro Namespace:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-namespace-prod
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: database # Aplica a regra no banco de dados
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          env: prod # Permite tráfego de namespaces com esta label
    ports:
    - protocol: TCP
      port: 5432

```

---

### 🌐 Parte 2: Ingress e Ingress Controllers

Para estes exercícios, assuma que você já tem dois Services criados no namespace `default`:

* Service `api-svc` na porta `80`
* Service `web-svc` na porta `80`

**Exercícios:**
**56.** Crie um recurso Ingress chamado `app-ingress`. Configure-o para que requisições para o caminho `/api` sejam direcionadas para o service `api-svc`.
**57.** Atualize o Ingress `app-ingress`. Agora, adicione uma regra de *Name-based virtual hosting*. Requisições para o host `site.com.br` no caminho `/` devem ser direcionadas para o `web-svc`.

---

#### Soluções - Parte 2

**56. Criando Ingress baseado em Path:**
Diferente dos YAMLs puros, o `kubectl create ingress` é seu melhor amigo aqui para poupar tempo na prova.

```sh
kubectl create ingress app-ingress --rule="/api*=api-svc:80"

```

*(Se você precisar do YAML imperativo para editar regras mais complexas depois: `kubectl create ingress app-ingress --rule="/api*=api-svc:80" --dry-run=client -o yaml > ingress.yaml`)*

**57. Name-based virtual hosting e múltiplos paths:**
Aqui, o mais rápido é editar o yaml gerado ou criar direto via arquivo. A estrutura final deve ficar assim:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: default
spec:
  rules:
  - host: site.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
  - http: # Esta é a regra do ex. 56 que atende qualquer host
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80

```

> [!IMPORTANT]
> *Dica de exame: Preste muita atenção no `pathType: Prefix` (ou `Exact`), pois as versões mais recentes da API `networking.k8s.io/v1` exigem esse campo.*
