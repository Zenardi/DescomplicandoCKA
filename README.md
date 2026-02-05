# Descomplicando a Certificação CKA


Treinamento para Cerificação Certified Kubernetes Administrator da [linuxTIPS](https://linuxtips.io)

# Conteúdo
WIP

<details>
<summary>DAY-01</summary>

- [DAY 01](day-01/README.md#day-01)
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
  - [Validando Instalacao](day-01/README.md#validando-instalacao)
  - [Instalando Cilium CNI](day-01/README.md#instalando-cilium-cni)
- [Backup do ETCD](day-01/README.md#backup-do-etcd)
- [Upgrade do Cluster 1.34 -\> 1.35](day-01/README.md#upgrade-do-cluster-134---135)
  - [1. Atualizar kubeadm no control plane](day-01/README.md#1-atualizar-kubeadm-no-control-plane)
  - [2. Aplicar o upgrade do control plane](day-01/README.md#2-aplicar-o-upgrade-do-control-plane)
  - [3. Atualizar kubelet e kubectl no control plane](day-01/README.md#3-atualizar-kubelet-e-kubectl-no-control-plane)
  - [4. Upgrade dos worker nodes](day-01/README.md#4-upgrade-dos-worker-nodes)
- [Materiais](day-01/README.md#materiais)
- [Exercicio](day-01/README.md#exercicio)
  - [Lista 1 - Day 1](day-01/README.md#lista-1---day-1)

</details>

---


# Certified Kubernetes Administrator (CKA) Curriculum

## Exam Description

The **CKA** certification is designed to ensure that Kubernetes administrators have the skills, knowledge, and competency to perform the responsibilities of Kubernetes administrators.
It demonstrates proficiency in installation, configuration, and management of Kubernetes clusters, including networking, storage, security, troubleshooting, and cluster maintenance.

The certification is intended for Kubernetes administrators, cloud administrators, and other IT professionals who manage Kubernetes clusters.
More information about the exam can be found on the [Linux Foundation Training website](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/).

## Domains & Weighting

| Domain                       | Weight |
|------------------------------|--------|
| Cluster Architecture, Installation & Configuration | 25% |
| Workloads & Scheduling       | 15%    |
| Services & Networking        | 20%    |
| Storage                      | 10%    |
| Troubleshooting              | 30%    |

