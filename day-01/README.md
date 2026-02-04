# DAY 01


# ControlPlane & Worker Node
```sh
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

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

#Containerd 

apt install -y containerd

mkdir -p /etc/containerd

containerd config default>/etc/containerd/config.toml

sed -i 's/SystemdCgroup.*/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl enable --now containerd
sudo systemctl status containerd
```


# Materiais
* https://kubernetes.io/docs/reference/setup-tools/kubeadm/


# Exercicio
## Lista 1 - Day 1

    1. Criar um cluster Kubernetes com pelo menos 1 worker node + 1 Control Plane na versão 1.31.
    2. Fazer o upgrade do Cluster para versão 1.32.
    3. Crie alguns recursos no cluster.
    4. Fazer o backup do ETCD para o path /tmp/cka-snapshot.db.
    5. Delete os itens criados na task 3.
    6. Faça o restore do cluster e garanta que os recursos criados na task 3 estejam criados.

O processo ideal é repetir essa lista pelo menos **10 vezes** durante todo treinamento.


