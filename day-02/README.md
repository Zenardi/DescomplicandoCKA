# CKA Study Guide: Pods e Fundamentos do Kubernetes

Este guia resume os conceitos fundamentais sobre a criação, gerenciamento e troubleshooting de Pods, com foco em boas práticas para o exame **Certified Kubernetes Administrator (CKA)**.

## 1. Modos de Criação de Recursos

No Kubernetes, existem duas abordagens principais para gerenciar objetos:

* **Imperativa:** Uso de comandos diretos (ex: `kubectl run`). É rápida e ideal para a prova.
* **Declarativa:** Uso de manifestos YAML com o comando `kubectl apply -f`. É a prática recomendada para produção e essencial para entender a estrutura dos objetos.

---

## 2. Anatomia de um Manifesto de Pod (YAML)

Um manifesto básico de Pod é composto por quatro campos obrigatórios:

1. **`apiVersion`**: Versão da API (para Pods, utiliza-se `v1`).
2. **`kind`**: Tipo do recurso (ex: `Pod`).
3. **`metadata`**: Dados de identificação (nome, namespace, labels).
4. **`spec`**: Definição do estado desejado (containers, imagens, portas, volumes).

---

## 3. Comandos Essenciais para o Dia a Dia

### Gerenciamento e Consulta

* `kubectl get po`: Lista os Pods (forma abreviada de `pods`).
* `kubectl describe pod <nome>`: O "melhor amigo" do administrador. Mostra detalhes do ciclo de vida, IP, Node e a **lista de eventos** (crucial para identificar erros de agendamento ou pull de imagem).
* `kubectl logs <nome>`: Visualiza a saída padrão do container.

### Exploração da API

* `kubectl api-resources`: Lista todos os recursos disponíveis no cluster e suas versões.
* `kubectl explain pod`: Documentação interativa via terminal. Use `kubectl explain pod.spec --recursive` para ver toda a árvore de campos disponíveis.

---

## 4. Otimização para a Prova: Dry Run e Imperatividade

Para ganhar tempo e evitar erros de sintaxe, utilize o **Dry Run**:

```bash
# Gera o YAML de um pod sem criá-lo no cluster
kubectl run meu-pod --image=nginx --dry-run=client -o yaml > pod.yaml

```

* **Edição rápida:** Use `kubectl replace --force -f pod.yaml` para deletar e recriar um pod instantaneamente.
* **Aceleração:** O parâmetro `--grace-period=0 --force` ignora o tempo de encerramento amigável, economizando segundos preciosos no exame.

---

## 5. Multi-Container Pods

* **Shared Network:** Containers no mesmo Pod compartilham o `localhost`. Se um container roda Nginx (80) e outro Redis (6379), eles se comunicam via `localhost:6379`.
* **Agendamento:** Todos os containers de um mesmo Pod são obrigatoriamente escalonados para o **mesmo Nó**.

---

## 6. Comandos e Argumentos (`command` vs `args`)

No Kubernetes, você pode sobrescrever as definições da imagem Docker:

* **`command`**: Sobrescreve o `ENTRYPOINT`.
* **`args`**: Sobrescreve o `CMD`.

**Exemplo de sintaxe:**

```yaml
spec:
  containers:
  - name: alpine
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "echo 'Estudando para a CKA' && sleep 3600"]

```

---

## 7. Estratégias de Sucesso e Segurança

* **Backup Sempre:** Antes de editar um recurso com `kubectl edit`, salve o estado atual: `kubectl get po <nome> -o yaml > backup-ex1.yaml`.
* **Organização:** Crie diretórios separados para cada questão ou exercício (Ex: `mkdir EX1`).
* **Cuidado com Tipografia:** Erros comuns incluem indentação incorreta, falta de dois pontos (`:`) ou confusão entre maiúsculas e minúsculas.
* **Não perca tempo com Aliases:** Foque em aprender o comando e o recurso. O tempo gasto configurando ambientes complexos de atalhos pode não compensar durante a prova.
* **Copy & Paste:** Sempre copie nomes de imagens e hashes diretamente do enunciado para evitar erros de digitação.

---

### 💡 Simulado Prático: Pods e Troubleshooting

#### Exercício 1: O Pod Imperativo

Crie um pod chamado `nginx-cka` usando a imagem `nginx:1.19`.

* O pod deve ter a label `env=prod`.
* Gere o arquivo YAML primeiro (`pod1.yaml`) e depois aplique-o.
* **Desafio:** Verifique em qual Nó (Node) o pod foi agendado sem usar o `describe`.

#### Exercício 2: O Multi-container "Sidecar"

Crie um pod chamado `multi-app` com dois containers:

1. Container principal: Imagem `nginx`.
2. Container auxiliar: Imagem `redis`.

* Exporte o YAML e verifique se ambos estão no mesmo pod.

#### Exercício 3: Sobrescrevendo Comandos

Crie um pod chamado `busybox-quic` usando a imagem `busybox`.

* O container deve executar o comando `sh -c "echo 'Kubernetes is awesome' && sleep 3600"`.
* Certifique-se de usar os campos `command` e `args` separadamente no YAML.

#### Exercício 4: O "Fast Delete" (Troca de Imagem)

Você tem um pod rodando com a imagem `nginx:1.14`. Você precisa atualizá-lo para `nginx:1.21` da forma mais rápida possível, forçando a substituição.

* Use o `kubectl get pod <nome> -o yaml > pod-update.yaml`.
* Altere a versão no arquivo.
* Use o comando `replace` com `--force` e `--grace-period=0`.

#### Exercício 5: Investigação (Troubleshooting)

Tente criar um pod com uma imagem que não existe (ex: `nginx:9999`).

1. Use o `kubectl describe` para identificar o erro exato nos **Events**.
2. Use o `kubectl explain pod.spec.containers` para descobrir como configurar a política de pull da imagem para `IfNotPresent`.

---

### 🛠️ Dicas de Ouro para a Prova:

* **Não digite YAML do zero:** Use sempre o `kubectl run ... --dry-run=client -o yaml`.
* **Shortcuts:** Use `po` para pods, `ns` para namespaces e `deploy` para deployments.
* **Auto-complete:** No início da prova, verifique se o autocomplete está ativo (`source <(kubectl completion bash)`).

---
