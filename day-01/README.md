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
apt install -y containerd

mkdir -p /etc/containerd

containerd config default>/etc/containerd/config.toml

sed -i 's/SystemdCgroup.*/SystemdCgroup = true/g' /etc/containerd/config.toml

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

# Adicione a seguinte linha no .bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
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

```sh
cilium install
```

Depois de instalado e de alguns minutos, voce pode constatar que o nó agora está Pronto (`Ready`).
```sh
> kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   30m   v1.34.3
```

# Materiais
* https://kubernetes.io/docs/reference/setup-tools/kubeadm/
* https://v1-34.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
* https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/
* https://github.com/techiescamp/cka-certification-guide
* https://github.com/Zenardi/vagrant-kubeadm-kubernetes


# Exercicio
## Lista 1 - Day 1

    1. Criar um cluster Kubernetes com pelo menos 1 worker node + 1 Control Plane na versão 1.31.
    2. Fazer o upgrade do Cluster para versão 1.32.
    3. Crie alguns recursos no cluster.
    4. Fazer o backup do ETCD para o path /tmp/cka-snapshot.db.
    5. Delete os itens criados na task 3.
    6. Faça o restore do cluster e garanta que os recursos criados na task 3 estejam criados.

O processo ideal é repetir essa lista pelo menos **10 vezes** durante todo treinamento.


