O RBAC (Role-Based Access Control) é um dos tópicos mais importantes nas provas CKA e CKAD. No exame, você precisará gerenciar "quem" (Subject: Usuários, Grupos ou ServiceAccounts) pode fazer "o quê" (Verbo: get, list, create, delete) e "onde" (Recurso: pods, secrets, nodes).

> [!IMPORTANT]
> A grande dica para o exame é: **nunca crie recursos RBAC escrevendo YAML do zero**. Os comandos imperativos do `kubectl` para criar Roles e RoleBindings economizam minutos preciosos.

Aqui estão os exercícios focados em segurança e controle de acesso.

---

### 🔐 Parte 5: RBAC (ServiceAccounts, Roles e Bindings)

Para estes exercícios, vamos operar no namespace `default`, a menos que especificado de outra forma.

**Exercícios:**

**66.** Crie uma `ServiceAccount` chamada `cicd-token`.
**67.** Crie uma `Role` chamada `pod-reader` que permita apenas as operações de leitura (`get`, `watch`, `list`) no recurso `pods`.
**68.** Crie um `RoleBinding` chamado `read-pods-binding` que vincule a `Role` `pod-reader` à `ServiceAccount` `cicd-token`.
**69.** Verifique e valide se a `ServiceAccount` `cicd-token` tem permissão para listar pods no namespace `default`. Em seguida, verifique se ela tem permissão para deletar pods (deve ser negado).
**70.** Crie uma `ClusterRole` chamada `node-viewer` que permita listar e visualizar (`get`, `list`, `watch`) os `nodes` do cluster. Em seguida, crie um `ClusterRoleBinding` chamado `view-nodes-global` vinculando esta regra ao usuário `admin-user`.

---

### 🛠️ Soluções - Parte 5

**66. Criar uma ServiceAccount:**
Comando direto e simples.

```sh
kubectl create serviceaccount cicd-token

```

**67. Criar uma Role (Imperativo):**
A sintaxe é `kubectl create role <NOME> --verb=<VERBOS> --resource=<RECURSOS>`.

```sh
kubectl create role pod-reader --verb=get,list,watch --resource=pods

```

**68. Criar o RoleBinding (Imperativo):**
A sintaxe é `kubectl create rolebinding <NOME> --role=<NOME_DA_ROLE> --serviceaccount=<NAMESPACE>:<NOME_DA_SA>`.
*(Atenção: ao vincular uma ServiceAccount via CLI, você deve especificar o namespace dela no formato `namespace:nome`, mesmo estando no namespace atual).*

```sh
kubectl create rolebinding read-pods-binding --role=pod-reader --serviceaccount=default:cicd-token

```

**69. Validar permissões (Auth can-i):**
O comando `auth can-i` é essencial no exame para testar suas próprias políticas RBAC sem precisar extrair tokens. O formato do usuário para ServiceAccounts é `system:serviceaccount:<namespace>:<nome>`.

```sh
# Deve retornar: yes
kubectl auth can-i list pods --as=system:serviceaccount:default:cicd-token

# Deve retornar: no
kubectl auth can-i delete pods --as=system:serviceaccount:default:cicd-token

```

**70. ClusterRole e ClusterRoleBinding:**
Roles e RoleBindings são limitados a um Namespace específico. Quando precisamos dar permissões a recursos de nível de cluster (como `nodes` ou `PersistentVolumes`) ou conceder acesso em todos os namespaces de uma vez, usamos a versão `Cluster`.

```sh
# Criando a ClusterRole
kubectl create clusterrole node-viewer --verb=get,list,watch --resource=nodes

# Criando o ClusterRoleBinding para um usuário específico (User)
kubectl create clusterrolebinding view-nodes-global --clusterrole=node-viewer --user=admin-user

```

*(Se fosse para uma ServiceAccount, o comando seria similar ao do exercício 68, usando a flag `--serviceaccount`).*

---
