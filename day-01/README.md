# DAY 01

- [DAY 01](#day-01)
- [Configurando o ControlPlane \& Worker Nodes](#configurando-o-controlplane--worker-nodes)
  - [1. Desativando de forma permanente o swap](#1-desativando-de-forma-permanente-o-swap)
  - [2. Habilitando os modulos `overlay` e `br_netfilter`](#2-habilitando-os-modulos-overlay-e-br_netfilter)
  - [3. Configurando parametros de `kubernetes.conf`](#3-configurando-parametros-de-kubernetesconf)
  - [4. Instalando o Containerd](#4-instalando-o-containerd)
  - [Instalando o kubelet, kubeadmin e kubectl](#instalando-o-kubelet-kubeadmin-e-kubectl)
    - [1. Update the apt package index and install packages needed to use the Kubernetes apt repository:](#1-update-the-apt-package-index-and-install-packages-needed-to-use-the-kubernetes-apt-repository)
    - [2. Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:](#2-download-the-public-signing-key-for-the-kubernetes-package-repositories-the-same-signing-key-is-used-for-all-repositories-so-you-can-disregard-the-version-in-the-url)
    - [3. Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.34; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version (you should also check that you are reading the documentation for the version of Kubernetes that you plan to install).](#3-add-the-appropriate-kubernetes-apt-repository-please-note-that-this-repository-have-packages-only-for-kubernetes-134-for-other-kubernetes-minor-versions-you-need-to-change-the-kubernetes-minor-version-in-the-url-to-match-your-desired-minor-version-you-should-also-check-that-you-are-reading-the-documentation-for-the-version-of-kubernetes-that-you-plan-to-install)
    - [4. Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:](#4-update-the-apt-package-index-install-kubelet-kubeadm-and-kubectl-and-pin-their-version)
    - [5. (Optional) Enable the kubelet service before running kubeadm:](#5-optional-enable-the-kubelet-service-before-running-kubeadm)
- [Init Control Plane config](#init-control-plane-config)
- [Setup Cilium CNI](#setup-cilium-cni)
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
You will install these packages on all of your machines:

* kubeadm: the command to bootstrap the cluster.

* kubelet: the component that runs on all of the machines in your cluster and does things like starting pods and containers.

* kubectl: the command line util to talk to your cluster.

> [!IMPORTANT]
> These instructions are for Kubernetes v1.34. 


### 1. Update the apt package index and install packages needed to use the Kubernetes apt repository:
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

### 2. Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:

```sh
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### 3. Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.34; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version (you should also check that you are reading the documentation for the version of Kubernetes that you plan to install).

```sh
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 4. Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
```sh
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 5. (Optional) Enable the kubelet service before running kubeadm:
```sh
sudo systemctl enable --now kubelet
```


# Init Control Plane config

```sh
kubeadm init

# To start using your cluster, you need to run the following as a regular user:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Adicione a seguinte linha no .bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
```

> [!TIP] Regerar o token que permite novos nodes se juntarem ao control plane 
>   ```sh
>   kubeadm token create --print-join-command
>
>   #kubeadm join <control-plane-ip>:6443 --token <token> \
>   #        --discovery-token-ca-cert-hash <ca-cert-hash>
>```

# Setup Cilium CNI
Depois de inicializar o control plane com `kubeadm init` e executar `kubectl get nodes` voce percebe que o status do controlplane nao esta pronto (`NotReady`). Isso acontece pois nao configuramos ainda uma `CNI` (**Container Network Interface**). Para corrigit isso, vamos usar o [Cilium](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/).

```sh
> kubectl get nodes
NAME           STATUS     ROLES           AGE   VERSION
controlplane   NotReady   control-plane   84s   v1.34.3
```

## Instalando Cilium
Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

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
To validate that Cilium has been properly installed, you can run
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

Run the following command to validate that your cluster has proper network connectivity:

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


