# DAY-02 - Explorando Pods e dry-run

- [DAY-02 - Explorando Pods e dry-run](#day-02---explorando-pods-e-dry-run)
  - [1. Modos de Operação: Imperativo vs. Declarativo](#1-modos-de-operação-imperativo-vs-declarativo)
  - [2. Anatomia de um Manifesto de Pod](#2-anatomia-de-um-manifesto-de-pod)
  - [3. Ferramentas de Exploração e Troubleshooting](#3-ferramentas-de-exploração-e-troubleshooting)
  - [4. Estratégia "Dry Run" (O Pulo do Gato para a CKA)](#4-estratégia-dry-run-o-pulo-do-gato-para-a-cka)
  - [5. Ciclo de Vida e Atualização de Pods](#5-ciclo-de-vida-e-atualização-de-pods)
  - [6. Multi-Container Pods \& Comunicação](#6-multi-container-pods--comunicação)
  - [7. Comandos e Argumentos (`command` e `args`)](#7-comandos-e-argumentos-command-e-args)
  - [8. Dicas de Ouro para o Dia da Prova](#8-dicas-de-ouro-para-o-dia-da-prova)
- [Desafios](#desafios)
  - [🚀 Desafio 1: O "Ninja" do Imperativo](#-desafio-1-o-ninja-do-imperativo)
  - [🛠️ Desafio 2: Multi-Container e Logs](#️-desafio-2-multi-container-e-logs)
  - [⚠️ Desafio 3: O "Fix-it" (Substituição Forçada)](#️-desafio-3-o-fix-it-substituição-forçada)
  - [📚 Tabela de Consulta Rápida: Campos do Manifesto](#-tabela-de-consulta-rápida-campos-do-manifesto)


## 1. Modos de Operação: Imperativo vs. Declarativo

No Kubernetes, você pode criar recursos de duas formas. Para a prova, a agilidade do imperativo combinada com a precisão do declarativo é a chave.

* **Imperativo (`kubectl run`):** Mais rápido para a prova. Cria o recurso diretamente.
* **Declarativo (`kubectl apply -f file.yaml`):** Utiliza arquivos de manifesto. Ideal para configurações complexas e histórico (GitOps).
* **Dica para a Prova:** Sempre que possível, gere o YAML de forma imperativa para não perder tempo digitando espaços e indentação manualmente.

---

## 2. Anatomia de um Manifesto de Pod

Todo objeto no Kubernetes segue uma estrutura básica. Memorizar os quatro campos de primeiro nível é essencial:

| Campo | Descrição | Exemplo (Pod) |
| --- | --- | --- |
| `apiVersion` | Versão da API do recurso | `v1` |
| `kind` | Tipo do objeto | `Pod` |
| `metadata` | Dados de identificação | `name`, `namespace`, `labels` |
| `spec` | Especificação do estado desejado | `containers`, `volumes`, `image` |

---

## 3. Ferramentas de Exploração e Troubleshooting

Estes comandos serão seus "melhores amigos" durante o exame:

* **`kubectl get po`:** Lista os pods (forma abreviada de `pods`).
* **`kubectl describe po <nome>`:** Mostra detalhes técnicos e, principalmente, a seção de **Events**. Se o pod não sobe, o motivo está no final do `describe`.
* **`kubectl explain <recurso>`:** Funciona como um "man" do Linux. Ex: `kubectl explain pod.spec.containers` mostra todos os campos possíveis para containers. Use `--recursive` para ver a árvore completa.
* **`kubectl logs <nome-do-pod>`:** Essencial para ver o que está acontecendo dentro da aplicação (ex: erro de conexão com banco).

---

## 4. Estratégia "Dry Run" (O Pulo do Gato para a CKA)

Para ganhar tempo, não escreva YAML do zero. Use o comando de criação simulada:

```bash
kubectl run meu-pod --image=nginx --dry-run=client -o yaml > pod.yaml

```

* `--dry-run=client`: Valida o comando sem criar o recurso no cluster.
* `-o yaml`: Exporta a saída no formato YAML.
* **Ação:** Edite o arquivo `pod.yaml` gerado e aplique com `kubectl apply -f pod.yaml`.

---

## 5. Ciclo de Vida e Atualização de Pods

* **Imutabilidade:** Pods são as menores unidades e não são "editáveis" em todos os campos. Se precisar mudar algo estrutural (como o comando), você deve substituir o pod.
* **`kubectl replace --force -f pod.yaml`:** Deleta o pod atual e cria um novo instantaneamente.
* **`--grace-period=0`:** Remove o tempo de espera de 30 segundos para o desligamento amigável. **Cuidado:** Use apenas se tiver certeza, para ganhar segundos preciosos na prova.

---

## 6. Multi-Container Pods & Comunicação

* **Shared Network:** Containers no mesmo Pod compartilham o mesmo IP e rede. Eles se comunicam via `localhost`.
* **Agendamento:** Eles sempre serão criados no **mesmo Node**.
* **Exemplo:** Um container de aplicação (Nginx) acessando um banco de cache (Redis) via `localhost:6379`.

---

## 7. Comandos e Argumentos (`command` e `args`)

Muitas questões pedem para alterar o comportamento padrão da imagem:

* **`command`:** Sobrescreve o `ENTRYPOINT` do Docker.
* **`args`:** Sobrescreve o `CMD` do Docker (passa parâmetros para o comando).
* **Sintaxe no YAML:**
```yaml
spec:
  containers:
  - name: alpine
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "echo Olá Mundo; sleep 3600"]

```



---

## 8. Dicas de Ouro para o Dia da Prova

1. **Backups são vida:** Antes de editar um recurso com `kubectl edit`, salve uma cópia (`kubectl get po nome -o yaml > backup.yaml`). Se você errar a indentação e o pod sumir, você tem o original.
2. **Organização:** Crie pastas por questão (`mkdir ex1`, `mkdir ex2`).
3. **Cuidado com Typo:** Erros de digitação em nomes de imagens ou labels invalidam a questão. **Copy-paste** os valores do enunciado sempre.
4. **Aliases:** Não perca tempo configurando dezenas de aliases. O comando `alias k=kubectl` e o autocomplete (`source <(kubectl completion bash)`) já são suficientes.

---



Perfeito! Vamos transformar esse guia em um **Simulado de Treinamento Intensivo** focado na realidade da prova CKA. Como a certificação é prática, a melhor forma de fixar é resolvendo cenários reais.

Abaixo, apresento um **Hands-on de Fixação** com 3 desafios baseados nos tópicos da aula.

---


# Desafios

## 🚀 Desafio 1: O "Ninja" do Imperativo

**Cenário:** Você precisa criar um Pod chamado `pod-nginx` no namespace `default`.

* **Imagem:** `nginx:alpine`
* **Label:** `tier=frontend`
* **Porta:** `80`
* **Tarefa:** Gere o arquivo `pod-nginx.yaml` sem criar o recurso, adicione manualmente uma variável de ambiente `APP_ENV=prod` no arquivo e então aplique.

**Comando Mestre:**

```bash
kubectl run pod-nginx --image=nginx:alpine --labels="tier=frontend" --port=80 --dry-run=client -o yaml > pod-nginx.yaml

```

> **Dica CKA:** Após gerar o YAML, abra com `vi pod-nginx.yaml` e insira a seção `env:` dentro de `containers:`.

---

## 🛠️ Desafio 2: Multi-Container e Logs

**Cenário:** Crie um Pod chamado `multi-app` com dois containers:

1. **Container 1:** Nome `app-server`, imagem `nginx`.
2. **Container 2:** Nome `log-shredder`, imagem `busybox`, rodando o comando `sh -c "while true; do echo 'Processando logs...'; sleep 10; done"`.

**Checklist de Troubleshooting:**

* Use `kubectl describe pod multi-app` para ver se ambos iniciaram.
* Use `kubectl logs multi-app -c log-shredder` para validar se o segundo container está escrevendo os logs.

---

## ⚠️ Desafio 3: O "Fix-it" (Substituição Forçada)

**Cenário:** Um Pod existente chamado `old-app` está rodando com a imagem `redis:5`. O examinador pede para você mudar a imagem para `redis:6` e adicionar o argumento `--appendonly yes`, mas o `kubectl edit` está dando erro de validação.

**Procedimento de Emergência:**

1. **Exportar:** `kubectl get pod old-app -o yaml > fix.yaml`
2. **Editar:** Mude a versão da imagem e adicione a seção `args: ["--appendonly", "yes"]`.
3. **Substituir:**

```bash
kubectl replace --force -f fix.yaml

```

*O `--force` garante que o K8s delete o antigo e crie o novo imediatamente, ignorando o tempo de espera padrão.*

---

## 📚 Tabela de Consulta Rápida: Campos do Manifesto

Para não se perder no `kubectl explain`, aqui está o mapa mental:

| Nível no YAML | Campo Chave | O que define? |
| --- | --- | --- |
| `metadata` | `annotations` | Notas não identificáveis (logs, descrições). |
| `spec` | `nodeName` | Força o Pod a rodar em um nó específico. |
| `spec.containers` | `imagePullPolicy` | `Always`, `Never` ou `IfNotPresent`. |
| `spec.containers` | `resources` | Limites de CPU e Memória (Essencial na CKA). |
| `spec.containers` | `volumeMounts` | Onde o disco será montado dentro do container. |

---

