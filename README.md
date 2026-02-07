# Descomplicando a Certificação CKA

Treinamento para Cerificação Certified Kubernetes Administrator da [LINUXtips](https://linuxtips.io). [Descomplicando a Certificação CKA](https://linuxtips.io/descomplicando-a-certificacao-cka/)

- [Descomplicando a Certificação CKA](#descomplicando-a-certificação-cka)
- [Conteúdo](#conteúdo)
    - [1. O Formato da Prova](#1-o-formato-da-prova)
    - [2. O Currículo (Domínios e Pesos)](#2-o-currículo-domínios-e-pesos)
      - [A. Troubleshooting (30%) - *A parte mais pesada*](#a-troubleshooting-30---a-parte-mais-pesada)
      - [B. Cluster Architecture, Install \& Configuration (25%)](#b-cluster-architecture-install--configuration-25)
      - [C. Services \& Networking (20%)](#c-services--networking-20)
      - [D. Workloads \& Scheduling (15%)](#d-workloads--scheduling-15)
      - [E. Storage (10%)](#e-storage-10)
    - [3. Dicas de Ouro para Passar](#3-dicas-de-ouro-para-passar)

# Conteúdo

<details>
<summary>DAY-01 - Configurando, Atualizando um Cluster Kubernetes e Backup/Restore do Etcd</summary>

- [DAY-01 - Configurando, Atualizando um Cluster Kubernetes e Backup/Restore do Etcd](day-01/README.md#day-01---configurando-atualizando-um-cluster-kubernetes-e-backuprestore-do-etcd)
- [Decidindo a versão do Kubernetes](day-01/README.md#decidindo-a-versão-do-kubernetes)
- [Configurando o ControlPlane \& Worker Nodes](day-01/README.md#configurando-o-controlplane--worker-nodes)
  - [1. Desativando de forma permanente o swap](day-01/README.md#1-desativando-de-forma-permanente-o-swap)
  - [2. Habilitando os modulos `overlay` e `br_netfilter`](day-01/README.md#2-habilitando-os-modulos-overlay-e-br_netfilter)
  - [3. Configurando parametros de `kubernetes.conf`](day-01/README.md#3-configurando-parametros-de-kubernetesconf)
  - [4. Instalando o Containerd](day-01/README.md#4-instalando-o-containerd)
  - [Instalando o kubelet, kubeadmin e kubectl](day-01/README.md#instalando-o-kubelet-kubeadmin-e-kubectl)
    - [1. Atualize o índice de pacotes do apt e instale os pacotes necessários para usar o repositório apt do Kubernetes](day-01/README.md#1-atualize-o-índice-de-pacotes-do-apt-e-instale-os-pacotes-necessários-para-usar-o-repositório-apt-do-kubernetes)
    - [2. Baixe a chave de assinatura pública para os repositórios de pacotes do Kubernetes. A mesma chave de assinatura é usada para todos os repositórios, portanto, você pode ignorar a versão na URL](day-01/README.md#2-baixe-a-chave-de-assinatura-pública-para-os-repositórios-de-pacotes-do-kubernetes-a-mesma-chave-de-assinatura-é-usada-para-todos-os-repositórios-portanto-você-pode-ignorar-a-versão-na-url)
    - [3. Adicione o repositório apt do Kubernetes apropriado. Observe que este repositório contém pacotes apenas para o Kubernetes `1.34`; para outras versões secundárias do Kubernetes, você precisa alterar a versão secundária do Kubernetes na URL para corresponder à versão desejada (você também deve verificar a documentação da versão do Kubernetes que pretende instalar)](day-01/README.md#3-adicione-o-repositório-apt-do-kubernetes-apropriado-observe-que-este-repositório-contém-pacotes-apenas-para-o-kubernetes-134-para-outras-versões-secundárias-do-kubernetes-você-precisa-alterar-a-versão-secundária-do-kubernetes-na-url-para-corresponder-à-versão-desejada-você-também-deve-verificar-a-documentação-da-versão-do-kubernetes-que-pretende-instalar)
    - [4. Atualize o índice de pacotes do apt, instale o kubelet, o kubeadm e o kubectl e fixe as versões correspondentes](day-01/README.md#4-atualize-o-índice-de-pacotes-do-apt-instale-o-kubelet-o-kubeadm-e-o-kubectl-e-fixe-as-versões-correspondentes)
    - [5. (Opcional) Habilite o serviço kubelet antes de executar o kubeadm](day-01/README.md#5-opcional-habilite-o-serviço-kubelet-antes-de-executar-o-kubeadm)
- [Inicializando o Control Plane com `kubeadm`](day-01/README.md#inicializando-o-control-plane-com-kubeadm)
- [Instalando o Cilium CNI](day-01/README.md#instalando-o-cilium-cni)
  - [Instalando Cilium](day-01/README.md#instalando-cilium)
  - [Instalando Cilium CNI](day-01/README.md#instalando-cilium-cni)
  - [Validando Instalação](day-01/README.md#validando-instalação)
  - [Criando um recurso dentro do nosso novo cluster](day-01/README.md#criando-um-recurso-dentro-do-nosso-novo-cluster)
- [Upgrade do Cluster 1.33 -\> 1.34](day-01/README.md#upgrade-do-cluster-133---134)
  - [1. Preparando os pacotes para atualizar kubeadm no control plane](day-01/README.md#1-preparando-os-pacotes-para-atualizar-kubeadm-no-control-plane)
    - [Editando o arquivo `/etc/apt/sources.list.d/kubernetes.list`](day-01/README.md#editando-o-arquivo-etcaptsourceslistdkuberneteslist)
    - [Adicionando o pacote com `curl`](day-01/README.md#adicionando-o-pacote-com-curl)
  - [2. Aplicar o upgrade do control plane](day-01/README.md#2-aplicar-o-upgrade-do-control-plane)
    - [2.1 Output do comando `kubeadm upgrade plan`](day-01/README.md#21-output-do-comando-kubeadm-upgrade-plan)
    - [2.2 Output do comando `kubeadm upgrade apply v1.34.3`](day-01/README.md#22-output-do-comando-kubeadm-upgrade-apply-v1343)
  - [3. Upgrade dos worker nodes](day-01/README.md#3-upgrade-dos-worker-nodes)
    - [3.1 Preparando o nó para manutenção](day-01/README.md#31-preparando-o-nó-para-manutenção)
- [O Backup e Restore do `etcd`](day-01/README.md#o-backup-e-restore-do-etcd)
  - [Instalar o `etcdctl`](day-01/README.md#instalar-o-etcdctl)
  - [Backup](day-01/README.md#backup)
  - [Dica de Produtividade (Simplificando o comando)](day-01/README.md#dica-de-produtividade-simplificando-o-comando)
  - [Restore](day-01/README.md#restore)
    - [Verificando o status do `backup`](day-01/README.md#verificando-o-status-do-backup)
    - [Restaurando o `snapshot`](day-01/README.md#restaurando-o-snapshot)
    - [Trobleshooting pós-restore](day-01/README.md#trobleshooting-pós-restore)
      - [1. O Comando Direto (Reiniciar o Serviço)](day-01/README.md#1-o-comando-direto-reiniciar-o-serviço)
      - [2. A Maneira "Mais Eficiente" para Static Pods (O Truque do Manifesto)](day-01/README.md#2-a-maneira-mais-eficiente-para-static-pods-o-truque-do-manifesto)
      - [3. Reiniciando o Container Runtime (Se tudo travar)](day-01/README.md#3-reiniciando-o-container-runtime-se-tudo-travar)
      - [Resumo: O que fazer pós-restore?](day-01/README.md#resumo-o-que-fazer-pós-restore)
  - [Pontos de atenção durante a prova](day-01/README.md#pontos-de-atenção-durante-a-prova)
- [Materiais](day-01/README.md#materiais)
- [Exercicio](day-01/README.md#exercicio)
  - [Lista 1 - Day 1](day-01/README.md#lista-1---day-1)

</details>



---


A prova **CKA (Certified Kubernetes Administrator)** é considerada uma das certificações mais respeitadas e práticas do mercado de TI. Diferente de provas teóricas de múltipla escolha (como as da AWS ou Azure), a CKA é **100% "mão na massa" (hands-on)**.

Aqui está um resumo estratégico do que esperar e como o currículo é dividido.

---

### 1. O Formato da Prova

* **Tipo:** Baseada em desempenho. Você recebe acesso a um terminal remoto no navegador e deve resolver problemas reais.
* **Duração:** 2 horas.
* **Questões:** Entre 15 e 20 cenários (tasks).
* **Nota de Corte:** 66% para passar.
* **Versão do Kubernetes:** Sempre a versão mais recente estável (atualmente v1.31+).
* **Consulta:** É **Open Book** (com restrições). Você pode ter uma aba aberta na documentação oficial (`kubernetes.io/docs`, `helm.sh/docs`, etc.).

> **O Grande Desafio:** O inimigo não é a dificuldade técnica, mas o **tempo**. Você tem cerca de 6 a 8 minutos por questão. Se você não souber gerar YAMLs imperativamente (via linha de comando), não terá tempo de terminar.

---

### 2. O Currículo (Domínios e Pesos)

A prova é dividida em 5 grandes áreas. Com base nas suas perguntas anteriores (etcd, static pods), você já está estudando o tópico de *Cluster Architecture*.

#### A. Troubleshooting (30%) - *A parte mais pesada*

É aqui que a maioria reprova. Você precisa consertar clusters quebrados.

* **O que cai:**
* Debugar nós que estão `NotReady`.
* Consertar falhas no Control Plane (kube-apiserver parado, kubelet com configuração errada).
* Resolver problemas de rede (Pods não se comunicam, Service não funciona).
* Debugar contêineres que não sobem (CrashLoopBackOff, ImagePullBackOff).



#### B. Cluster Architecture, Install & Configuration (25%)

* **O que cai:**
* **Backup e Restore do etcd** (Sua pergunta anterior! Isso cai 99% das vezes).
* Upgrade do cluster (usando `kubeadm upgrade`).
* Gerenciamento de RBAC (Role, ClusterRole, ServiceAccount).
* Instalação básica via `kubeadm`.



#### C. Services & Networking (20%)

* **O que cai:**
* **Network Policies:** Bloquear ou liberar tráfego entre pods (ex: "só permitir que o pod A fale com o B").
* Services (ClusterIP, NodePort) e Ingress.
* Configuração de DNS (CoreDNS) e CNI.



#### D. Workloads & Scheduling (15%)

* **O que cai:**
* Deployments, DaemonSets e StatefulSets.
* ConfigMaps e Secrets (injetar variáveis de ambiente).
* Scheduling manual (NodeSelector, Affinity, Taints & Tolerations).
* Padrões de Pods (Sidecar, InitContainers).



#### E. Storage (10%)

* **O que cai:**
* PersistentVolumes (PV) e PersistentVolumeClaims (PVC).
* StorageClasses.
* Montar volumes dentro dos Pods.



---

### 3. Dicas de Ouro para Passar

1. **Domine o `kubectl` Imperativo:**
Esqueça copiar e colar YAML do zero. Use comandos para gerar o esqueleto:
* Pod: `kubectl run nginx --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml`
* Deployment: `kubectl create deploy web --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml`
* Service: `kubectl expose deploy web --port=80 --target-port=8080 --type=NodePort --dry-run=client -o yaml > svc.yaml`


2. **Aliases são Vida:**
No início da prova, configure:
```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
# Agora você pode rodar: k run pod1 --image=nginx $do

```


3. **Atenção ao Contexto:**
A prova tem vários clusters (k8s, hk8s, bk8s, etc.). Cada questão começa com um comando em negrito: `kubectl config use-context <nome>`. **Nunca esqueça de rodar isso**, ou você vai consertar o cluster errado e zerar a questão.
4. **Use a Documentação a seu favor:**
Aprenda a pesquisar (Ctrl+F) na documentação. Saiba onde estão as páginas de "etcd backup", "network policies" e "persistent volumes". Copie os exemplos de YAML de lá.


