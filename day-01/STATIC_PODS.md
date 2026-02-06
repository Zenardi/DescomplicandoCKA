**Static Pods** (Pods Estáticos) são pods gerenciados diretamente pelo daemon do **kubelet** em um nó específico, sem a intervenção do API Server ou do Scheduler do Kubernetes.

Eles são a peça fundamental para o "bootstrapping" (inicialização) de um cluster Kubernetes, pois resolvem o problema do "ovo e da galinha": como rodar o Kubernetes se os componentes necessários para rodá-lo (como o Scheduler) ainda não estão ativos?

Aqui está uma explicação detalhada de como eles funcionam e seu papel nos manifestos do Control Plane.

---

### 1. Como funcionam os Static Pods?

Diferente dos Pods normais (que são gerenciados por Deployments ou ReplicaSets e agendados pelo Scheduler), os Static Pods têm um ciclo de vida diferente:

* **Gerenciamento Local:** O `kubelet` (o agente que roda em cada nó) é configurado para monitorar um diretório específico no sistema de arquivos do servidor (geralmente `/etc/kubernetes/manifests`).
* **Criação Automática:** Se você colocar um arquivo YAML de definição de Pod nesse diretório, o kubelet detecta o arquivo e inicia o Pod imediatamente.
* **Recuperação Automática:** Se o processo do Pod morrer, o kubelet tenta reiniciá-lo.
* **Remoção:** Se você apagar o arquivo YAML desse diretório, o kubelet mata o Pod.
* **Imutabilidade via API:** Você **não pode** editar ou atualizar um Static Pod através do `kubectl` ou do API Server. A fonte da verdade é o arquivo no disco.

#### O Conceito de "Mirror Pod"

Embora o API Server não gerencie esses pods, o kubelet tenta criar um **Mirror Pod** no API Server. Isso serve apenas para que o Pod fique visível quando você roda `kubectl get pods`. É como um "fantasma" ou um reflexo somente leitura do pod real.

---

### 2. O Papel no Control Plane

Em clusters criados com ferramentas modernas como o `kubeadm`, os componentes críticos do Control Plane rodam como **Static Pods**.

Imagine o cenário de inicialização:

1. O servidor liga. O `systemd` inicia o serviço do `kubelet`.
2. O `kubelet` lê a pasta `/etc/kubernetes/manifests`.
3. Ele encontra os YAMLs dos componentes vitais e inicia os containers.
4. Só então o cluster passa a existir e responder a comandos.

#### Quais componentes são Static Pods?

Se você entrar no nó master de um cluster `kubeadm` e listar o diretório, verá algo assim:

```bash
ls /etc/kubernetes/manifests/
# Saída comum:
# etcd.yaml
# kube-apiserver.yaml
# kube-controller-manager.yaml
# kube-scheduler.yaml

```

Cada um desses arquivos garante que esses serviços essenciais estejam sempre rodando naquele nó específico.

| Componente | Por que é Static Pod? |
| --- | --- |
| **etcd** | O banco de dados precisa subir antes de tudo para armazenar o estado do cluster. |
| **kube-apiserver** | É o cérebro. Sem ele, ninguém fala com o cluster. Ele precisa subir via Kubelet porque o Scheduler ainda não existe. |
| **kube-scheduler** | Precisa estar rodando para agendar *outros* pods, mas ele mesmo não pode depender do agendamento. |
| **kube-controller-manager** | Gerencia os controladores principais (Nodes, Replicas, etc). |

---

### 3. Diferenças Práticas: Pod Normal vs. Static Pod

| Característica | Pod Normal | Static Pod |
| --- | --- | --- |
| **Quem cria?** | API Server + Scheduler | Kubelet (lendo arquivo local) |
| **Onde reside?** | Em qualquer nó (decisão do Scheduler) | Preso ao nó onde o arquivo está |
| **Como deletar?** | `kubectl delete pod ...` | `rm /etc/kubernetes/manifests/arquivo.yaml` |
| **Alta Disponibilidade** | Controlada por ReplicaSet/Deployment | Depende do nó estar vivo. Se o nó morrer, o Pod morre. |
| **Uso principal** | Aplicações do usuário, Ingress, etc. | Infraestrutura base do Kubernetes (Control Plane) |

### Dica de Troubleshooting

Se você precisar alterar um parâmetro do `kube-apiserver` (por exemplo, habilitar um feature gate ou mudar uma flag de autenticação):

1. Você deve editar o arquivo `/etc/kubernetes/manifests/kube-apiserver.yaml` diretamente no nó master.
2. O kubelet detectará a mudança no hash do arquivo.
3. Ele irá **reiniciar** o Pod do API Server automaticamente com a nova configuração.

> **Cuidado:** Se você cometer um erro de sintaxe YAML neste arquivo, o Control Plane pode falhar e o cluster ficará inacessível até você corrigir o arquivo manualmente via SSH no nó.
