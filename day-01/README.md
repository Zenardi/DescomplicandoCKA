# DAY-01 - Configurando, Atualizando um Cluster Kubernetes e Backup/Restore do Etcd

- [DAY-01 - Configurando, Atualizando um Cluster Kubernetes e Backup/Restore do Etcd](#day-01---configurando-atualizando-um-cluster-kubernetes-e-backuprestore-do-etcd)
- [Decidindo a versão do Kubernetes](#decidindo-a-versão-do-kubernetes)
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
  - [Instalando Cilium CNI](#instalando-cilium-cni)
  - [Validando Instalação](#validando-instalação)
  - [Criando um recurso dentro do nosso novo cluster](#criando-um-recurso-dentro-do-nosso-novo-cluster)
- [Upgrade do Cluster 1.33 -\> 1.34](#upgrade-do-cluster-133---134)
  - [1. Preparando os pacotes para atualizar kubeadm no control plane](#1-preparando-os-pacotes-para-atualizar-kubeadm-no-control-plane)
    - [Editando o arquivo `/etc/apt/sources.list.d/kubernetes.list`](#editando-o-arquivo-etcaptsourceslistdkuberneteslist)
    - [Adicionando o pacote com `curl`](#adicionando-o-pacote-com-curl)
  - [2. Aplicar o upgrade do control plane](#2-aplicar-o-upgrade-do-control-plane)
    - [2.1 Output do comando `kubeadm upgrade plan`](#21-output-do-comando-kubeadm-upgrade-plan)
    - [2.2 Output do comando `kubeadm upgrade apply v1.34.3`](#22-output-do-comando-kubeadm-upgrade-apply-v1343)
  - [3. Upgrade dos worker nodes](#3-upgrade-dos-worker-nodes)
    - [3.1 Preparando o nó para manutenção](#31-preparando-o-nó-para-manutenção)
- [O Backup e Restore do `etcd`](#o-backup-e-restore-do-etcd)
  - [Instalar o `etcdctl`](#instalar-o-etcdctl)
  - [Backup](#backup)
  - [Dica de Produtividade (Simplificando o comando)](#dica-de-produtividade-simplificando-o-comando)
  - [Restore](#restore)
    - [Verificando o status do `backup`](#verificando-o-status-do-backup)
    - [Restaurando o `snapshot`](#restaurando-o-snapshot)
    - [Trobleshooting pós-restore](#trobleshooting-pós-restore)
      - [1. O Comando Direto (Reiniciar o Serviço)](#1-o-comando-direto-reiniciar-o-serviço)
      - [2. A Maneira "Mais Eficiente" para Static Pods (O Truque do Manifesto)](#2-a-maneira-mais-eficiente-para-static-pods-o-truque-do-manifesto)
      - [3. Reiniciando o Container Runtime (Se tudo travar)](#3-reiniciando-o-container-runtime-se-tudo-travar)
      - [Resumo: O que fazer pós-restore?](#resumo-o-que-fazer-pós-restore)
  - [Pontos de atenção durante a prova](#pontos-de-atenção-durante-a-prova)
- [Materiais](#materiais)
- [Exercicio](#exercicio)
  - [Lista 1 - Day 1](#lista-1---day-1)


# Decidindo a versão do Kubernetes
Para iniciarmos esta brincaderia de instalar, configurar nosso cluster e após fazer o upgrade, precisamos primeiro definir qual versão instalaremos para não termos muitos problemas no upgrade. 

Como vamos trabalhar com o `Cilium` como nosso CNI, precisamos verificar sua matriz de compatilidade e verificar se a nova versão é compativel com o Cilium pois se o `Cilium` não suportar (ainda) a nova versão, não conseguiremos fazer o upgrade. 

Para isso, precisamos acessar a pagina de compatibilidade do kubernetes do Cilium. Acesse clicando [aqui](https://docs.cilium.io/en/latest/network/kubernetes/compatibility/). No momento da escrita deste documento, a versao 1.35 **não** esta na lista. 

| k8s Version | k8s NetworkPolicy API | CiliumNetworkPolicy |
|-------------|-----------------------|---------------------|
| 1.31, 1.32, 1.33, 1.34 | networking.k8s.io/v1 | `cilium.io/v2` has a [CustomResourceDefinition](https://docs.cilium.io/en/latest/glossary/#term-CustomResourceDefinition) |

*Tabela extraida do site oficial da Cilium*

Segundo a tabela, as versoes 1.33 e 1.34 sao compativeis, portanto o **plano** é instalarmos a versao `1.33` e realizarmos o upgrade para `1.34`.


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
sudo su -
sudo apt-get update
sudo apt install -y containerd

sudo mkdir -p /etc/containerd

sudo containerd config default>/etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup.*/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl enable --now containerd
sudo systemctl restart containerd
sudo systemctl status containerd
```


## Instalando o kubelet, kubeadmin e kubectl
Você instalará estes pacotes em todas as suas máquinas:

* `kubeadm`: o comando para inicializar o cluster.

* `kubelet`: o componente que é executado em todas as máquinas do seu cluster e realiza tarefas como iniciar pods e contêineres.

* `kubectl`: o utilitário de linha de comando para se comunicar com o seu cluster.

> [!IMPORTANT]
> Estas instrucoes sao para o Kubernetes v1.33. 


### 1. Atualize o índice de pacotes do apt e instale os pacotes necessários para usar o repositório apt do Kubernetes
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

### 2. Baixe a chave de assinatura pública para os repositórios de pacotes do Kubernetes. A mesma chave de assinatura é usada para todos os repositórios, portanto, você pode ignorar a versão na URL

```sh
# Se o diretório `/etc/apt/keyrings` não existir, ele deverá ser criado antes do comando curl, leia a nota abaixo.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### 3. Adicione o repositório apt do Kubernetes apropriado. Observe que este repositório contém pacotes apenas para o Kubernetes `1.34`; para outras versões secundárias do Kubernetes, você precisa alterar a versão secundária do Kubernetes na URL para corresponder à versão desejada (você também deve verificar a documentação da versão do Kubernetes que pretende instalar)

```sh
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
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
> Execute estes comandos apenas no `Control Plane`. 

> [!CAUTION]
> Se estiver usando o laboratório de Vagrant, use este comando para inicializar o control plane
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

# Adicione a seguinte linha no final do .bashrc no usuario root
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
Depois de inicializar o control plane com `kubeadm init` e executar `kubectl get nodes` voce percebe que o status do `Control Plane` não esta pronto (`NotReady`). Isso acontece pois não configuramos ainda uma `CNI` (**Container Network Interface**). Para corrigir isso, vamos usar o [Cilium](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/).

```sh
> kubectl get nodes
NAME           STATUS     ROLES           AGE     VERSION
controlplane   NotReady   control-plane   6m38s   v1.33.7
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
NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   3m58s   v1.33.7
```

Depois de fazer o setup nos `Worker Nodes` o daemon set do Cilium se encarregara de instalar o CNI nele e depois de ingressar no `Control Plane`, o `Worker Node` ira aparecer como Pronto (`Ready`).
```sh
> kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   74m   v1.33.3
node01         Ready    <none>          73m   v1.33.3
```

## Validando Instalação
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


# Upgrade do Cluster 1.33 -> 1.34
Estas etapas assumem Ubuntu/Debian e Kubernetes 1.33 já instalado. Execute **primeiro no control plane**, depois em cada worker.

## 1. Preparando os pacotes para atualizar kubeadm no control plane
Primeiro precisamos fazer a atualizacao dos pacotes, ou em outras palavras mudar o repositorio de pacotes para a nova versao. Podemos manualmente trocar a versao simplesmente editando o arquivo ou executando o comando para adicinar o pacote da nova versao

### Editando o arquivo `/etc/apt/sources.list.d/kubernetes.list`
Guia: [Link](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/)
Open the file that defines the Kubernetes apt repository using a text editor of your choice:
```sh
nano /etc/apt/sources.list.d/kubernetes.list

# You should see a single line with the URL that contains your current Kubernetes minor version. For example, if you're using v1.33, you should see this:
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /

# Change the version in the URL to the next available minor release, for example:
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /
```

### Adicionando o pacote com `curl`
```sh
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Sobreescreva o arquivo quando perguntado...
File '/etc/apt/keyrings/kubernetes-apt-keyring.gpg' exists. Overwrite? (y/N) y


echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualize os pacotes da maquina
sudo apt update -y

# Resultado
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  InRelease [1,227 B]
Get:8 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  Packages [6,868 B]
```

Com os pacotes do apt atualizados, temos que primeiro destravar (**unhold**) o pacote do 'kubeadm' para que possamos de fato atualizar a versao. 

```sh
sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get install kubeadm kubectl kubelet

# Resultado
After this operation, 21.8 MB disk space will be freed.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  kubeadm 1.34.3-1.1 [10.8 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  kubectl 1.34.3-1.1 [10.0 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  kubelet 1.34.3-1.1 [11.0 MB]
Fetched 31.8 MB in 3s (11.7 MB/s)
Reading changelogs... Done
(Reading database ... 36378 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.34.3-1.1_arm64.deb ...
Unpacking kubeadm (1.34.3-1.1) over (1.33.7-1.1) ...
Preparing to unpack .../kubectl_1.34.3-1.1_arm64.deb ...
Unpacking kubectl (1.34.3-1.1) over (1.33.7-1.1) ...
Preparing to unpack .../kubelet_1.34.3-1.1_arm64.deb ...
Unpacking kubelet (1.34.3-1.1) over (1.33.7-1.1) ...
Setting up kubeadm (1.34.3-1.1) ...
Setting up kubectl (1.34.3-1.1) ...
Setting up kubelet (1.34.3-1.1) ...

# Verificando o update
kubectl version

# Resultado
Client Version: v1.34.3
Kustomize Version: v5.7.1
Server Version: v1.33.7
```

## 2. Aplicar o upgrade do control plane
```sh
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.34.3
sudo systemctl restart kubelet

# Coloque os pacotes em espera (hold) novamente
sudo apt-mark unhold kubeadm kubelet kubectl
```

### 2.1 Output do comando `kubeadm upgrade plan`
```sh
> sudo kubeadm upgrade plan


[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade/config] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.33.7
[upgrade/versions] kubeadm version: v1.34.3
I0207 16:52:59.425413    3449 version.go:260] remote version is much newer: v1.35.0; falling back to: stable-1.34
[upgrade/versions] Target version: v1.34.3
[upgrade/versions] Latest version in the v1.33 series: v1.33.7

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE           CURRENT   TARGET
kubelet     controlplane   v1.33.7   v1.34.3
kubelet     node01         v1.33.7   v1.34.3

Upgrade to the latest stable version:

COMPONENT                 NODE           CURRENT    TARGET
kube-apiserver            controlplane   v1.33.7    v1.34.3
kube-controller-manager   controlplane   v1.33.7    v1.34.3
kube-scheduler            controlplane   v1.33.7    v1.34.3
kube-proxy                               1.33.7     v1.34.3
CoreDNS                                  v1.12.0    v1.12.1
etcd                      controlplane   3.5.24-0   3.6.5-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.34.3

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

### 2.2 Output do comando `kubeadm upgrade apply v1.34.3`

```sh
> sudo kubeadm upgrade apply v1.34.3

[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade/preflight] Running preflight checks
[upgrade] Running cluster health checks
[upgrade/preflight] You have chosen to upgrade the cluster version to "v1.34.3"
[upgrade/versions] Cluster version: v1.33.7
[upgrade/versions] kubeadm version: v1.34.3
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/preflight] Pulling images required for setting up a Kubernetes cluster
[upgrade/preflight] This might take a minute or two, depending on the speed of your internet connection
[upgrade/preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W0207 16:54:38.400655    3466 checks.go:827] detected that the sandbox image "registry.k8s.io/pause:3.6" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.1" as the CRI sandbox image.
[upgrade/control-plane] Upgrading your static Pod-hosted control plane to version "v1.34.3" (timeout: 5m0s)...
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests515426523"
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/etcd.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-02-07-16-55-05/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-02-07-16-55-05/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-02-07-16-55-05/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-02-07-16-55-05/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upgrade/control-plane] The control plane instance for this node was successfully upgraded!
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upgrade/kubeconfig] The kubeconfig files for this node were successfully upgraded!
W0207 16:57:39.495196    3466 postupgrade.go:116] Using temporary directory /etc/kubernetes/tmp/kubeadm-kubelet-config594129382 for kubelet config. To override it set the environment variable KUBEADM_UPGRADE_DRYRUN_DIR
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config594129382/config.yaml
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade/kubelet-config] The kubelet configuration for this node was successfully upgraded!
[upgrade/bootstrap-token] Configuring bootstrap token and cluster-info RBAC rules
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

[upgrade] SUCCESS! A control plane node of your cluster was upgraded to "v1.34.3".

[upgrade] Now please proceed with upgrading the rest of the nodes by following the right order.
```


Com o `Control Plane` atualizado vamos agora atualizar o `Worker Node`.

## 3. Upgrade dos worker nodes
Como vamos colocar um nó em manutencao, precisamos adicionar uma `taint` nele para conseguir fazer o upgrade. Vamos fazer isso usando `kubectl drain`. Este comando prepara o nó para fazer o upgrade. Quando estamos trabalhando com clusters de alta-disponibilidade (HA), este comando irá remover tudo que esta agendado neste nó e vai move-los para outros nós para que não tenhamos um *downtime* neste processo. 

### 3.1 Preparando o nó para manutenção

Ainda dentro do nó do `Control Plane`...

> [!TIP] 
> Substituia `node01` para o nome do nó que deseja fazer o upgrade.

```sh
kubectl get no

NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6h19m   v1.34.3
node01         Ready    <none>          4h50m   v1.33.7

kubectl drain node01 --ignore-daemonsets --force

# Output
node/node01 cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/cilium-49h88, kube-system/cilium-envoy-rtwkx, kube-system/kube-proxy-b582t
evicting pod kube-system/coredns-66bc5c9577-qv24g
evicting pod default/nginx-66fc78d4b8-wtjlq
evicting pod kube-system/coredns-66bc5c9577-qf7pm
pod/nginx-66fc78d4b8-wtjlq evicted
pod/coredns-66bc5c9577-qf7pm evicted
pod/coredns-66bc5c9577-qv24g evicted
node/node01 drained
```

Agora nosso nó esta pronto para manutenção. Veja o novo status do nó. Perceba o status `SchedulingDisabled`.
```sh
kubectl get no

NAME           STATUS                   ROLES              AGE            VERSION
controlplane   Ready                    control-plane      6h19m          v1.34.0
node01         Ready,SchedulingDisabled <none>             4h50m          v1.33.7
```

Dentro do `Worker Node`, repita o processo de atualização

```sh
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Sobreescreva o arquivo quando perguntado...
File '/etc/apt/keyrings/kubernetes-apt-keyring.gpg' exists. Overwrite? (y/N) y


echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualize os pacotes da maquina
sudo apt update -y

# Resultado
Get:6 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  InRelease [1,227 B]
Get:8 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.34/deb  Packages [6,868 B]
```


Com os pacotes do apt atualizando, temos que primeiro destravar (**unhold**) o pacote do `kubeadm` para que possamos de fato atualizar a versão. 

```sh
sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get install kubeadm kubectl kubelet
sudo systemctl restart kubelet

# Verificando o update
kubectl version

Client Version: v1.34.3
Kustomize Version: v5.7.1
Server Version: v1.33.7
```

> [!NOTE]
> Aqui finalizamos o processo de upgrade do nosso nó! Hora de travar as versões e colocar o nó como disponivel novamente.

Travando o versão do kubeadm, kubelet e kubectl
```sh
sudo apt-mark hold kubeadm kubelet kubectl
```

> [!TIP] 
> Substituia `node01` para o nome do nó que deseja fazer o upgrade.

Agora precisamos deixar novamente nosso nó disponivel. Dentro do `Control Plane` execute o comando abaixo
```sh
kubectl uncordon node01
```

> [!IMPORTANT] 
> Na prova, você não precisa instalar a CNI, **SE** pedirem para instalar a CNI, eles irão prover todos os manifestos para você apenas aplicar.


# O Backup e Restore do `etcd`
Documentação: 
  * [Operating etcd clusters for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

O `backup` consiste em tirar um snapshot e salvar em algum lugar, depois faremos o `restore` dele.

## Instalar o `etcdctl`
> [!NOTE]
> Na prova, esta ferramenta já irá estar previamente instalada no ambiente e pronta para usar.

```sh
# Para instalar em arquitetura x86_64
ETCD_VER=v3.5.21

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mv /tmp/etcd-download-test /usr/local/bin/

# Verificar
etcdctl version


# Para instalr em arquitetura ARM (e.g.: VM rodando em Vagrant no MacOS)
# Definir versão
ETCD_VER=v3.5.21

# Detectar arquitetura automaticamente (amd64 ou arm64)
ARCH=$(dpkg --print-architecture)
echo "Arquitetura detectada: $ARCH"

# Configurar URLs
GOOGLE_URL=https://storage.googleapis.com/etcd
DOWNLOAD_URL=${GOOGLE_URL}

# Limpar instalações anteriores ou arquivos temporários
rm -f /tmp/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

# Baixar o arquivo correto para a sua arquitetura
echo "Baixando etcd ${ETCD_VER} para ${ARCH}..."
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz

# Extrair
tar xzvf /tmp/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz -C /tmp/etcd-download-test --strip-components=1

# Instalar (Mover APENAS os binários, não a pasta)
echo "Instalando binários em /usr/local/bin..."
sudo mv /tmp/etcd-download-test/etcd /usr/local/bin/
sudo mv /tmp/etcd-download-test/etcdctl /usr/local/bin/
sudo mv /tmp/etcd-download-test/etcdutl /usr/local/bin/ 2>/dev/null || true # etcdutl existe em versões mais novas

# Limpeza
rm -f /tmp/etcd-${ETCD_VER}-linux-${ARCH}.tar.gz
rm -rf /tmp/etcd-download-test

# Testar
echo "Verificação de versão:"
etcdctl version
```

> [!TIP]
> TUDO relacionado ao nosso cluster está no diretório `/etc/kubernetes/manifests/`. É o diretório mais imporante
>  

Dentro de `/etc/kubernetes/manifests/` exitem os `Static Pods` e quem tem a responsabilidade de subir eles é o `kubelet`
```sh
ls /etc/kubernetes/manifests/

etcd.yaml
kube-apiserver.yaml
kube-controller-manager.yaml
kube-scheduler.yaml
```

`Static Pods` (Pods Estáticos) são pods gerenciados diretamente pelo daemon do kubelet em um nó específico, sem a intervenção do API Server ou do Scheduler do Kubernetes.

Eles são a peça fundamental para o "bootstrapping" (inicialização) de um cluster Kubernetes, pois resolvem o problema do "ovo e da galinha": como rodar o Kubernetes se os componentes necessários para rodá-lo (como o Scheduler) ainda não estão ativos?

## Backup

Fazer o backup do etcd consiste, basicamente, em tirar um "retrato" (`snapshot`) do estado atual do banco de dados.

Para um cluster provisionado com `kubeadm` (padrão de mercado e exames CKA), você deve rodar os comandos abaixo logado no nó do `Control Plane`.

```sh
ETCDCTL_API=3 sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db

# Output
{"level":"info","ts":"2026-02-07T17:21:03.745106Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/tmp/etcd-backup.db.part"}
{"level":"info","ts":"2026-02-07T17:21:03.751179Z","logger":"client","caller":"v3@v3.5.21/maintenance.go:212","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2026-02-07T17:21:03.751228Z","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"https://127.0.0.1:2379"}
{"level":"info","ts":"2026-02-07T17:21:03.807807Z","logger":"client","caller":"v3@v3.5.21/maintenance.go:220","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2026-02-07T17:21:03.834885Z","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"https://127.0.0.1:2379","size":"7.1 MB","took":"now"}
{"level":"info","ts":"2026-02-07T17:21:03.835124Z","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/tmp/etcd-backup.db"}
Snapshot saved at /tmp/etcd-backup.db
```

**O que cada flag faz:**

* `ETCDCTL_API=3`: Força o uso da API versão 3 (obrigatório).

* `--endpoints`: O endereço onde o etcd está escutando (localmente no master). Note o https.

* `--cacert`: O certificado da Autoridade Certificadora para validar o servidor.

* `--cert`: O seu certificado de cliente (para provar quem você é).

* `--key`: A chave privada do seu certificado.

* `snapshot save`: A instrução para salvar o arquivo.

* `/tmp/etcd-backup.db`: O local e nome do arquivo de backup.

> [!TIP] 
> O ponto chave na prova é decorar onde estão os arquivos de chave (`--cacert`, `--cert` e `--key`). Para encontrar estas informações, você pode simplesmente verificar o arquivo de static pod etcd em `/etc/kubernetes/manifests/etcd.yaml`.

## Dica de Produtividade (Simplificando o comando)
```sh
# 1. Definir variáveis
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

# 2. Rodar o backup (agora bem mais curto)
etcdctl snapshot save /tmp/snapshot-db
```

O snapshot do etcd salva os dados (Deployments, Services, ConfigMaps, etc.). Porém, para uma recuperação completa de desastre (Disaster Recovery), recomenda-se fazer backup também dos arquivos estáticos de configuração:
```sh
# Backup dos manifestos e configs
sudo mkdir /backup 
sudo cp -r /etc/kubernetes/ /backup/kubernetes-config/
sudo cp -r /var/lib/etcd/ /backup/etcd-data-raw/
```


## Restore
Restaurar o etcd é uma operação de "cirurgia de coração aberto" no cluster. O procedimento envolve parar o etcd atual, gerar uma nova estrutura de dados a partir do backup e apontar o Kubernetes para essa nova estrutura.

Apenas para verificar nosso snapshot, voce pode criar dois recursos - no exemplo um `configmap` e um `deployment`, e realizar o backup. Isso apenas para voce verificar o retore em acao.

> [!TIP] 
> Na prova, garanta que exista algum recurso antes de realizar o processo de `backup` e `restore` para comprovar para os avaliadores da prova que o processo funcionou.


```sh
kubectl create configmap restore
kubectl create deployment restore --image nginx
```


### Verificando o status do `backup`

```sh
ETCDCTL_API=3 etcdutl snapshot status /tmp/etcd-backup.db --write-out=table

+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| bea45243 |     8464 |       1972 |     7.1 MB |
+----------+----------+------------+------------+
```


### Restaurando o `snapshot`

Restaurando o `snapshot`:
```sh
# Define onde está o backup e para onde vai a restauração
BACKUP_FILE="/tmp/etcd-backup.db"
DATA_DIR="/var/lib/etcd-backup"

sudo etcdutl snapshot restore $BACKUP_FILE --data-dir $DATA_DIR

# Output
2026-02-07T17:40:43Z	info	snapshot/v3_snapshot.go:265	restoring snapshot	{"path": "/tmp/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap", "initial-memory-map-size": 10737418240}
2026-02-07T17:40:43Z	info	membership/store.go:138	Trimming membership information from the backend...
2026-02-07T17:40:43Z	info	membership/cluster.go:421	added member	{"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"], "added-peer-is-learner": false}
2026-02-07T17:40:43Z	info	snapshot/v3_snapshot.go:293	restored snapshot	{"path": "/tmp/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap", "initial-memory-map-size": 10737418240}
```

Navegue até a definição do etcd em `/etc/kubernetes/manifests/etcd.yaml` e altere os pontos de montagem e o comando de inicialização. Veja no exemplo abaixo.

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/etcd.advertise-client-urls: https://192.168.1.10:2379
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=https://192.168.1.10:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    # - --data-dir=/var/lib/etcd # <-- MUDE ISTO PARA /var/lib/etcd-backup
    - --data-dir=/var/lib/etcd-backup
    - --initial-advertise-peer-urls=https://192.168.1.10:2380
    - --initial-cluster=k8s-master=https://192.168.1.10:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --listen-client-urls=https://127.0.0.1:2379,https://192.168.1.10:2379
    - --listen-metrics-urls=http://127.0.0.1:2381
    - --listen-peer-urls=https://192.168.1.10:2380
    - --name=k8s-master
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    image: registry.k8s.io/etcd:3.5.10-0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /health
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: etcd
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /health
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    # - mountPath: /var/lib/etcd #  # <--- MUDE ISTO PARA /var/lib/etcd-backup
    - mountPath: /var/lib/etcd-backup
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      # path: /var/lib/etcd   # <--- MUDE ISTO PARA /var/lib/etcd-backup
      path: /var/lib/etcd-backup
      type: DirectoryOrCreate
    name: etcd-data
status: {}
```

> [!TIP] 
> Durante este processo, derrubamos todo o cluster, mas é o esperado. Ao alterar este arquivo o kubelet vai reiniciar e o cluster demora um pouco para voltar. Se demorar muito, voce reiniciar o serviço do kubelet.


### Trobleshooting pós-restore

Para reiniciar o serviço do `kubelet` (que é um serviço do sistema operacional gerenciado pelo systemd e não um Pod), você deve usar o comando padrão do Linux.

No entanto, no contexto de um **restore do etcd**, existem duas abordagens: reiniciar o **serviço** (daemon) ou forçar a recriação do **Pod estático**.

Aqui estão as opções:

#### 1. O Comando Direto (Reiniciar o Serviço)

Se você quer apenas reiniciar o agente do Kubelet para garantir que ele releia as configurações ou destrave:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**Para verificar se ele subiu corretamente:**

```bash
sudo systemctl status kubelet
```

---

#### 2. A Maneira "Mais Eficiente" para Static Pods (O Truque do Manifesto)

Muitas vezes, apenas reiniciar o serviço `kubelet` não é suficiente se o Pod do etcd estiver "preso" ou em um estado zumbi. O `kubelet` pode achar que o pod ainda está rodando e não aplicar as mudanças.

A maneira mais agressiva e garantida de forçar o etcd a subir com a nova configuração (restore) é simular a remoção e adição do arquivo:

1. **Mova o manifesto para fora da pasta monitorada:**
Isso faz o Kubelet acreditar que você deletou o Pod. Ele vai matar o processo do etcd imediatamente.
```bash
mv /etc/kubernetes/manifests/etcd.yaml /tmp/
```


2. **Aguarde alguns segundos (importante):**
Espere uns 10 a 20 segundos. Você pode verificar com `crictl ps` para garantir que o container do etcd sumiu.
3. **Mova o manifesto de volta:**
O Kubelet detecta um "novo" arquivo e inicia um processo limpo do zero.
```bash
mv /tmp/etcd.yaml /etc/kubernetes/manifests/
```



#### 3. Reiniciando o Container Runtime (Se tudo travar)

Se mesmo reiniciando o kubelet o pod não sobe (comum em erros de `CRI` ou sockets presos), reinicie o motor de containers antes de reiniciar o kubelet:

**Para containerd (padrão atual):**

```bash
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

**Para Docker (versões antigas):**

```bash
sudo systemctl restart docker
sudo systemctl restart kubelet
```

#### Resumo: O que fazer pós-restore?

Geralmente, a sequência de ouro para garantir que o restore foi aplicado é:

1. Editar o `/etc/kubernetes/manifests/etcd.yaml` (alterando o path do volume).
2. Se o pod não reiniciar sozinho em 1 minuto -> **Use o método 2 (Mover arquivo)**.
3. Se ainda falhar -> **Use o método 1 (Systemctl restart kubelet)**.


## Pontos de atenção durante a prova 
- Onde se encontram as chaves para fazer o backup/restore
- Onde ira salvar
- Path do arquivo
- Fazer o restore de um backup ja existem e garantir que o backup foi feito
- Fazer backup e retore

> [!IMPORTANT]
> O processo de correção é automatizado, então não podemos errar o caminho e nome de nada.
> Deixe seu conheciento mecânico/automático. É uma prova de **performance**.



# Materiais
* [Setup Tools - kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
* [Create Cluster kubeadm](https://v1-34.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
* [Install kubeadm](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/)
* [Git Repo CKA Guide](https://github.com/techiescamp/cka-certification-guide)
* [Upgrade do Cluster com kubeadm](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
* [Operating etcd clusters for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
* [Etcd Install](https://etcd.io/docs/v3.5/install/)


# Exercicio
## Lista 1 - Day 1

    1. Criar um cluster Kubernetes com pelo menos 1 worker node + 1 Control Plane na versão 1.31.
    2. Fazer o upgrade do Cluster para versão 1.32.
    3. Crie alguns recursos no cluster.
    4. Fazer o backup do ETCD para o path /tmp/cka-snapshot.db.
    5. Delete os itens criados na task 3.
    6. Faça o restore do cluster e garanta que os recursos criados na task 3 estejam criados.

O processo ideal é repetir essa lista pelo menos **10 vezes** durante todo treinamento.


