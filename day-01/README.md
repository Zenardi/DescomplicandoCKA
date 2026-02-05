# DAY 01

- [DAY 01](#day-01)
- [Configurando o ControlPlane \& Worker Nodes](#configurando-o-controlplane--worker-nodes)
  - [1. Desativando de forma permanente o swap](#1-desativando-de-forma-permanente-o-swap)
  - [2. Habilitando os modulos `overlay` e `br_netfilter`](#2-habilitando-os-modulos-overlay-e-br_netfilter)
  - [3. Configurando parametros de `kubernetes.conf`](#3-configurando-parametros-de-kubernetesconf)
  - [4. Instalando o Containerd](#4-instalando-o-containerd)
  - [Instalando o kubelet, kubeadmin e kubectl](#instalando-o-kubelet-kubeadmin-e-kubectl)
    - [1. Atualize o índice de pacotes do apt e instale os pacotes necessários para usar o repositório apt do Kubernetes](#1-atualize-o-índice-de-pacotes-do-apt-e-instale-os-pacotes-necessários-para-usar-o-repositório-apt-do-kubernetes)
    - [2. Baixe a chave de assinatura pública para os repositórios de pacotes do Kubernetes. A mesma chave de assinatura é usada para todos os repositórios, portanto, você pode ignorar a versão na URL](#2-baixe-a-chave-de-assinatura-pública-para-os-repositórios-de-pacotes-do-kubernetes-a-mesma-chave-de-assinatura-é-usada-para-todos-os-repositórios-portanto-você-pode-ignorar-a-versão-na-url)
    - [3. Adicione o repositório apt do Kubernetes apropriado. Observe que este repositório contém pacotes apenas para o Kubernetes `1.34`; para outras versões secundárias do Kubernetes, você precisa alterar a versão secundária do Kubernetes na URL para corresponder à versão desejada (você também deve verificar a documentação da versão do Kubernetes que pretende instalar)](#3-adicione-o-repositório-apt-do-kubernetes-apropriado-observe-que-este-repositório-contém-pacotes-apenas-para-o-kubernetes-134-para-outras-versões-secundárias-do-kubernetes-você-precisa-alterar-a-versão-secundária-do-kubernetes-na-url-para-corresponder-à-versão-desejada-você-também-deve-verificar-a-documentação-da-versão-do-kubernetes-que-pretende-instalar)
    - [4. Atualize o índice de pacotes do apt, instale o kubelet, o kubeadm e o kubectl e fixe as versões correspondentes](#4-atualize-o-índice-de-pacotes-do-apt-instale-o-kubelet-o-kubeadm-e-o-kubectl-e-fixe-as-versões-correspondentes)
    - [5. (Opcional) Habilite o serviço kubelet antes de executar o kubeadm](#5-opcional-habilite-o-serviço-kubelet-antes-de-executar-o-kubeadm)
- [Inicializando o Control Plane com `kubeadm`](#inicializando-o-control-plane-com-kubeadm)
- [Instalando o Cilium CNI](#instalando-o-cilium-cni)
  - [Instalando Cilium](#instalando-cilium)
  - [Validando Instalacao](#validando-instalacao)
  - [Instalando Cilium CNI](#instalando-cilium-cni)
  - [Criando um recurso dentro do nosso novo cluster](#criando-um-recurso-dentro-do-nosso-novo-cluster)
- [Backup do ETCD](#backup-do-etcd)
- [Upgrade do Cluster 1.34 -\> 1.35](#upgrade-do-cluster-134---135)
  - [1. Preparando os pacotes para atualizar kubeadm no control plane](#1-preparando-os-pacotes-para-atualizar-kubeadm-no-control-plane)
    - [Editando o arquivo `/etc/apt/sources.list.d/kubernetes.list`](#editando-o-arquivo-etcaptsourceslistdkuberneteslist)
    - [Adicionando o pacote com `curl`](#adicionando-o-pacote-com-curl)
  - [2. Aplicar o upgrade do control plane](#2-aplicar-o-upgrade-do-control-plane)
    - [2.1 Output do comando plan](#21-output-do-comando-plan)
  - [3. Upgrade dos worker nodes](#3-upgrade-dos-worker-nodes)
    - [3.1 Preparando o nó para manutenção](#31-preparando-o-nó-para-manutenção)
- [Materiais](#materiais)
- [Exercicio](#exercicio)
  - [Lista 1 - Day 1](#lista-1---day-1)


# Configurando o ControlPlane & Worker Nodes

Execute estes passos para configurar o *`Control Plane`* e *`Worker Nodes`*.

## 1. Desativando de forma permanente o swap
As vezes ao desativar o swap apenas usando `sudo swapoff -a` nao eh o suficiente, precisamos desabilitar de forma permanente e mais '**bruta**', para que depois de um reboot, a configuracao nao volte.

```sh
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo rm -f /swap.img
sudo systemctl daemon-reload
```

## 2. Habilitando os modulos `overlay` e `br_netfilter`
```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

## 3. Configurando parametros de `kubernetes.conf`
```sh
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv6.conf.all.rp_filter = 0
EOF

sudo sysctl --system
```


## 4. Instalando o Containerd 

```sh
sudo apt-get update
sudo apt install -y containerd

sudo mkdir -p /etc/containerd

sudo containerd config default>/etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup.*/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl enable --now containerd
sudo systemctl status containerd
```


## Instalando o kubelet, kubeadmin e kubectl
Você instalará estes pacotes em todas as suas máquinas:

* `kubeadm`: o comando para inicializar o cluster.

* `kubelet`: o componente que é executado em todas as máquinas do seu cluster e realiza tarefas como iniciar pods e contêineres.

* `kubectl`: o utilitário de linha de comando para se comunicar com o seu cluster.

> [!IMPORTANT]
> Estas instrucoes sao para o Kubernetes v1.34. 


### 1. Atualize o índice de pacotes do apt e instale os pacotes necessários para usar o repositório apt do Kubernetes
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

### 2. Baixe a chave de assinatura pública para os repositórios de pacotes do Kubernetes. A mesma chave de assinatura é usada para todos os repositórios, portanto, você pode ignorar a versão na URL

```sh
# Se o diretório `/etc/apt/keyrings` não existir, ele deverá ser criado antes do comando curl, leia a nota abaixo.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### 3. Adicione o repositório apt do Kubernetes apropriado. Observe que este repositório contém pacotes apenas para o Kubernetes `1.34`; para outras versões secundárias do Kubernetes, você precisa alterar a versão secundária do Kubernetes na URL para corresponder à versão desejada (você também deve verificar a documentação da versão do Kubernetes que pretende instalar)

```sh
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 4. Atualize o índice de pacotes do apt, instale o kubelet, o kubeadm e o kubectl e fixe as versões correspondentes
```sh
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 5. (Opcional) Habilite o serviço kubelet antes de executar o kubeadm
```sh
sudo systemctl enable --now kubelet
```


# Inicializando o Control Plane com `kubeadm`
Hora de inicializar nosso control plane. Para isso execute siga as instrucoes abaixo.

> [!IMPORTANT]
> Execute estes comandos apenas na maquina responsavel por ser o `control plane`. 

> [!CAUTION]
> Se estiver usando o laboratorio de Vagrant, use este comando para inicializar o control plane
> ```sh
> sudo kubeadm init --apiserver-advertise-address=192.168.201.10
> ```
> O API server do Vagrant está no IP da rede privada (192.168.201.10), veja o `settings.yaml`




```sh
# Execute este comando para fazer o setup do control plane do Kubernetes
kubeadm init

# Caso esteja usando o setup local com Vagrant, use
kubeadm init --apiserver-advertise-address=192.168.201.10

# Para iniciar o uso do cluster, voce precisa executar as seguintes linhas de comand usando o usuario regular (sem ser root)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Adicione a seguinte linha no final do .bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf

# Recarregue o .bashrc
source .bashrc
```

> [!TIP] 
> Regerar o token que permite novos nodes se juntarem ao control plane 
> 
>   ```sh
>   kubeadm token create --print-join-command
>
>   #kubeadm join <control-plane-ip>:6443 --token <token> \
>   #        --discovery-token-ca-cert-hash <ca-cert-hash>
>```

# Instalando o Cilium CNI
Depois de inicializar o control plane com `kubeadm init` e executar `kubectl get nodes` voce percebe que o status do controlplane nao esta pronto (`NotReady`). Isso acontece pois nao configuramos ainda uma `CNI` (**Container Network Interface**). Para corrigit isso, vamos usar o [Cilium](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/).

```sh
> kubectl get nodes
NAME           STATUS     ROLES           AGE   VERSION
controlplane   NotReady   control-plane   84s   v1.34.3
```

## Instalando Cilium
Instale a versão mais recente da CLI do Cilium. A CLI do Cilium pode ser usada para instalar o Cilium, inspecionar o estado de uma instalação do Cilium e ativar/desativar vários recursos (por exemplo, clustermesh, Hubble).

```sh
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

## Validando Instalacao
Para verificar se o Cilium foi instalado corretamente, você pode executar o seguinte comando:
```sh
> cilium status --wait

   /¯¯\
/¯¯\__/¯¯\    Cilium:         OK
\__/¯¯\__/    Operator:       OK
/¯¯\__/¯¯\    Hubble:         disabled
\__/¯¯\__/    ClusterMesh:    disabled
   \__/

DaemonSet         cilium             Desired: 2, Ready: 2/2, Available: 2/2
Deployment        cilium-operator    Desired: 2, Ready: 2/2, Available: 2/2
Containers:       cilium-operator    Running: 2
                  cilium             Running: 2
Image versions    cilium             quay.io/cilium/cilium:v1.9.5: 2
                  cilium-operator    quay.io/cilium/operator-generic:v1.9.5: 2
```

Execute o seguinte comando para validar se o seu cluster possui conectividade de rede adequada:

```
> cilium connectivity test

ℹ️  Monitor aggregation detected, will skip some flow validation steps
✨ [k8s-cluster] Creating namespace for connectivity check...
(...)
---------------------------------------------------------------------------------------------------------------------
📋 Test Report
---------------------------------------------------------------------------------------------------------------------
✅ 69/69 tests successful (0 warnings)

```

## Instalando Cilium CNI
Para instalar o Cilium simplesmente execute

> [!CAUTION]
> Se estiver usando o laboratorio de Vagrant, use este comando para instalar o Cilium
> ```sh
> cilium install --set k8sServiceHost=192.168.201.10 --set k8sServicePort=6443
> ```
> O API server do Vagrant está no IP da rede privada (192.168.201.10), veja o `settings.yaml`

```sh
cilium install

# Caso esteja usando o setup local com Vagrant, use
cilium install --set k8sServiceHost=192.168.201.10 --set k8sServicePort=6443
```

Depois de instalado e de alguns minutos, voce pode constatar que o nó agora está Pronto (`Ready`).
```sh
> kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   30m   v1.34.3
```

Depois de fazer o setup nos `Worker Nodes` o daemon set do Cilium se encarregara de instalar o CNI nele e depois de ingressar no `Control Plane`, o `Worker Node` ira aparecer como Pronto (`Ready`).
```sh
> kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   74m   v1.34.3
node01         Ready    <none>          73m   v1.34.3
```

## Criando um recurso dentro do nosso novo cluster
Dentro do `Control Plane`, vamos criar um simples NGINX.

```sh
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
EOF
```

# Backup do ETCD
Execute no **control plane**:

```sh
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/cka-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/cka-snapshot.db
```

# Upgrade do Cluster 1.34 -> 1.35
Estas etapas assumem Ubuntu/Debian e Kubernetes 1.34 já instalado. Execute **primeiro no control plane**, depois em cada worker.

> [!CAUTION]
> Ao fazer o upgrade da versao 1.34 para 1.35 existe uma **breaking change**. A flag `--pod-infra-container-image` foi removida do comando `kubelet`. Esta flag foi descontinuada (`deprecated`) nesta versao e removida. 
> Para evitar que tudo se quebre no upgrade, antes de instalar os novos binarios com `sudo apt-get install kubeadm kubectl kubelet`, remova esta flag do arquivo de argumentos do kubelet usando
> ```sh
> sudo sed -i 's#--pod-infra-container-image=registry.k8s.io/pause:3.10.1##g' /var/lib/kubelet/kubeadm-flags.env
>```
> Fonte: [Link](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.35.md#:~:text=Removed%20the%20%2D%2Dpod%2Dinfra%2Dcontainer%2Dimage%20flag%20from%20kubelet%27s%20command%20line.)


## 1. Preparando os pacotes para atualizar kubeadm no control plane
Primeiro precisamos fazer a atualizacao dos pacotes, ou em outras palavras mudar o repositorio de pacotes para a nova versao. Podemos manualmente trocar a versao simplesmente editando o arquivo ou executando o comando para adicinar o pacote da nova versao

### Editando o arquivo `/etc/apt/sources.list.d/kubernetes.list`
Guia: [Link](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/)
Open the file that defines the Kubernetes apt repository using a text editor of your choice:
```sh
nano /etc/apt/sources.list.d/kubernetes.list

# You should see a single line with the URL that contains your current Kubernetes minor version. For example, if you're using v1.34, you should see this:
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /

# Change the version in the URL to the next available minor release, for example:
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /
```

### Adicionando o pacote com `curl`
```sh
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Sobreescreva o arquivo quando perguntado...
File '/etc/apt/keyrings/kubernetes-apt-keyring.gpg' exists. Overwrite? (y/N) y


echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualize os pacotes da maquina
sudo apt update -y

# Resultado
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.35/deb  InRelease [1,227 B]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.35/deb  Packages [2,708 B]
```

Com os pacotes do apt atualizando, temos que primeiro destravar (**unhold**) o pacote do kubeadm para que possamos de fato atualizar a versao. 

```sh
# Como na versao 1.35 possui uma breaking change com a flag --pod-infra-container-image, onde a mesma nao existe nesta versao, precisamos remover ela do arquivo de parametros, para isso execute:
sudo sed -i 's#--pod-infra-container-image=registry.k8s.io/pause:3.10.1##g' /var/lib/kubelet/kubeadm-flags.env

# Reiniciao servico do kubelet
sudo systemctl restart kubelet

sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get install kubeadm kubectl kubelet

# Verificando o update
kubectl version

kubeadm version: &version.Info{Major:"1", Minor:"35", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.35.0", GitCommit:"66452049f3d692768c39c797b21b793dce80314e", GitTreeState:"clean", BuildDate:"2025-12-17T12:39:26Z", GoVersion:"go1.25.5", Compiler:"gc", Platform:"linux/arm64"}


kubectl get no

NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6h5m    **v1.35.0**
node01         Ready    <none>          4h36m   v1.34.3
```

## 2. Aplicar o upgrade do control plane
```sh
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.35

# Coloque os pacotes em espera (hold) novamente
sudo apt-mark unhold kubeadm kubelet kubectl
```

### 2.1 Output do comando plan
```sh
sudo kubeadm upgrade plan
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade/config] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.34.3
[upgrade/versions] kubeadm version: v1.35.0
[upgrade/versions] Target version: v1.35.0
[upgrade/versions] Latest version in the v1.34 series: v1.34.3

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE           CURRENT   TARGET
kubelet     node01         v1.34.3   v1.35.0
kubelet     controlplane   v1.35.0   v1.35.0

Upgrade to the latest stable version:

COMPONENT                 NODE           CURRENT   TARGET
kube-apiserver            controlplane   v1.34.3   v1.35.0
kube-controller-manager   controlplane   v1.34.3   v1.35.0
kube-scheduler            controlplane   v1.34.3   v1.35.0
kube-proxy                               1.34.3    v1.35.0
CoreDNS                                  v1.12.1   v1.13.1
etcd                      controlplane   3.6.5-0   3.6.6-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.35.0

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________
```


Com o `Control Plane` atualizado vamos agora atualizar o `Worker Node`.

## 3. Upgrade dos worker nodes
Como vamos colocar um nó em manutencao, precisamos adicionar uma `taint` nele para conseguir fazer o upgrade. Vamos fazer isso usando `kubectl drain`. Este comando prepara o nó para fazer o upgrade. Quando estamos trabalhando com clusters de alta-disponibilidade (HA), este comando ira remover tudo que esta agendado neste nó e vai move-los para outros nós para que não tenhamos um *downtime* neste processo. 

Ainda dentro do nó do Control Plane...
### 3.1 Preparando o nó para manutenção

```sh
kubectl get no

NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6h19m   v1.35.0
node01         Ready    <none>          4h50m   v1.34.3

kubectl drain node01 --ignore-daemonsets --force
```




# Materiais
* https://kubernetes.io/docs/reference/setup-tools/kubeadm/
* https://v1-34.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
* https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/
* https://github.com/techiescamp/cka-certification-guide
* https://github.com/Zenardi/vagrant-kubeadm-kubernetes
* [Upgrade do Cluster com kubeadm](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)


# Exercicio
## Lista 1 - Day 1

    1. Criar um cluster Kubernetes com pelo menos 1 worker node + 1 Control Plane na versão 1.31.
    2. Fazer o upgrade do Cluster para versão 1.32.
    3. Crie alguns recursos no cluster.
    4. Fazer o backup do ETCD para o path /tmp/cka-snapshot.db.
    5. Delete os itens criados na task 3.
    6. Faça o restore do cluster e garanta que os recursos criados na task 3 estejam criados.

O processo ideal é repetir essa lista pelo menos **10 vezes** durante todo treinamento.


