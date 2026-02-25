# DAY-03 - Explorando ConfigMaps e Secrets

- [DAY-03 - Explorando ConfigMaps e Secrets](#day-03---explorando-configmaps-e-secrets)
    - [1. Variáveis de Ambiente (Environment Variables)](#1-variáveis-de-ambiente-environment-variables)
    - [2. ConfigMaps](#2-configmaps)
      - [Criação de ConfigMaps (Prática Imperativa)](#criação-de-configmaps-prática-imperativa)
      - [3 Formas de Injetar um ConfigMap no Pod](#3-formas-de-injetar-um-configmap-no-pod)
    - [3. Secrets](#3-secrets)


### 1. Variáveis de Ambiente (Environment Variables)

Variáveis de ambiente evitam que as configurações fiquem *hardcoded* (fixas) no código da aplicação. No Kubernetes, elas são definidas a nível de contêiner.

* **Definição no YAML:** São declaradas em formato de lista chave-valor dentro do bloco `env` do contêiner.
* **Criação Imperativa Rápida:** Você pode injetar uma variável diretamente ao rodar um pod usando:
`kubectl run meu-pod --image=nginx --env="cor=azul"`
* **Validação no Contêiner:** Um exercício comum da CKA é coletar variáveis e salvar em um arquivo de texto.
`kubectl exec meu-pod -- env > env.txt`
* **Atualização de Pods:** Para aplicar mudanças rapidamente (já que alguns campos de Pods são imutáveis), substitua o pod forçando a deleção:
`kubectl replace --force --grace-period=0 -f pod.yaml`

---

### 2. ConfigMaps

O ConfigMap é o recurso ideal para lidar com variáveis e arquivos de configuração de forma dinâmica, separando a configuração da imagem do contêiner. (`apiVersion: v1`)

#### Criação de ConfigMaps (Prática Imperativa)

* **Literal:** `kubectl create configmap config-01 --from-literal=cor=azul --from-literal=ambiente=prod`
* **Arquivo de Variáveis:** `kubectl create configmap config-02 --from-env-file=meu-arquivo.env` (Lê os pares chave-valor).
* **Arquivo Completo:** `kubectl create configmap config-03 --from-file=meu-arquivo.conf` (Importa o conteúdo inteiro do arquivo).
* *Nota sobre chaves:* Em pares chave-valor, a chave precisa ser uma *string* (não pode começar com número inteiro). Dependendo da versão, valores numéricos no YAML precisam estar entre aspas.

#### 3 Formas de Injetar um ConfigMap no Pod

1. **Exportar tudo como Variáveis de Ambiente:** Usa-se `envFrom` referenciando o ConfigMap através de `configMapRef`. Todas as chaves do ConfigMap viram variáveis de ambiente.
2. **Exportar uma chave específica como Variável:** Usa-se `env` com `valueFrom` e `configMapKeyRef`. **Dica:** O nome da variável de ambiente no contêiner pode ser diferente do nome da chave no ConfigMap.
3. **Montar como Volume:** Permite que múltiplos contêineres compartilhem a configuração.
* Define-se o volume a nível do Pod apontando para o ConfigMap.
* Define-se o `volumeMounts` a nível do contêiner (ex: `/etc/config`).
* Pode-se montar o ConfigMap inteiro ou especificar itens individuais (ex: montar apenas a chave `cor` no caminho `cor`). A performance de leitura não é afetada por ser um arquivo montado.



**Atenção ao ciclo de vida:** Se você alterar o valor de um ConfigMap (via `kubectl edit` ou aplicando um novo YAML), o Pod precisa ser recriado para enxergar as novas variáveis (para Deployments, usa-se `rollout restart`). O uso do `kubectl edit` em produção exige cautela devido ao risco de perda de histórico; prefira editar o YAML e fazer o apply.

---

### 3. Secrets

Secrets funcionam da mesma forma estrutural que os ConfigMaps, mas são utilizados para dados sensíveis (senhas, tokens, chaves), pois armazenam a informação codificada. (`apiVersion: v1`, `kind: Secret`)

* **Codificação Base64:** O Kubernetes armazena os dados do Secret em Base64 (que é um *encode*, não uma criptografia forte).
* **O "Pulo do Gato" do Echo:** Ao gerar o Base64 manualmente no terminal, **sempre use a flag `-n**`.
`echo -n "minha-senha" | base64`
Isso evita que a quebra de linha do shell seja embutida no hash, o que mudaria a senha e causaria falhas de autenticação na aplicação. A quebra de linha depende do shell/terminal, não do tamanho da string.
* **Criação Imperativa Automática:** Ao usar o comando imperativo, o Kubernetes já faz o *encode* correto nos bastidores, prevenindo o erro da quebra de linha:
`kubectl create secret generic minha-secret --from-literal=senha=12345`
* **Injeção no Pod:** A sintaxe de injeção é idêntica à do ConfigMap, porém utilizando `secretKeyRef` em vez de `configMapKeyRef`.

- [DAY-03 - Explorando ConfigMaps e Secrets](#day-03---explorando-configmaps-e-secrets)
    - [1. Variáveis de Ambiente (Environment Variables)](#1-variáveis-de-ambiente-environment-variables)
    - [2. ConfigMaps](#2-configmaps)
      - [Criação de ConfigMaps (Prática Imperativa)](#criação-de-configmaps-prática-imperativa)
      - [3 Formas de Injetar um ConfigMap no Pod](#3-formas-de-injetar-um-configmap-no-pod)
    - [3. Secrets](#3-secrets)
