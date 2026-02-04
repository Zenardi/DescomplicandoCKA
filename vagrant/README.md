This setup creates a CKA-ready environment with **Ubuntu 22.04**, **Containerd** (the exam standard runtime), and **Kubeadm**.

### 1. Directory Structure

Create a folder for your project and create these two files inside it:

* `Vagrantfile`
* `setup.sh`

### 2. The Vagrantfile

This configuration defines two VMs (`controlplane` and `node01`) with private static IPs.

```ruby
Vagrant.configure("2") do |config|
  # Global config: Ubuntu 22.04 (Jammy Jellyfish)
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_check_update = false

  # Resource Configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  # Provisioning script (runs on all nodes)
  config.vm.provision "shell", path: "setup.sh"

  # --- Control Plane Node ---
  config.vm.define "controlplane" do |cp|
    cp.vm.hostname = "controlplane"
    cp.vm.network "private_network", ip: "192.168.56.10"
  end

  # --- Worker Node ---
  config.vm.define "node01" do |worker|
    worker.vm.hostname = "node01"
    worker.vm.network "private_network", ip: "192.168.56.11"
  end
end

```

### 3. The Setup Script (`setup.sh`)

This script automates the tedious prerequisites: disabling swap, loading kernel modules, and installing `containerd` and `kubeadm`.

```bash
#!/bin/bash
# setup.sh

# 1. Disable Swap (Required for Kubelet)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Load Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 3. Configure Sysctl for Networking
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 4. Install Containerd
sudo apt-get update
sudo apt-get install -y containerd

# 5. Configure Containerd to use SystemdCgroup (Critical for CKA)
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 6. Install Kubeadm, Kubelet, and Kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download Google Cloud public signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

```

### 4. How to Initialize the Cluster

Once the files are created, open your terminal in that folder:

**Step 1: Start the VMs**

```bash
vagrant up

```

**Step 2: Initialize Control Plane**
SSH into the control plane:

```bash
vagrant ssh controlplane

```

Run the initialization command (specifying the private IP is safer for Vagrant environments):

```bash
# Run this INSIDE the controlplane VM
sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=192.168.0.0/16

```

* **Important:** Copy the `kubeadm join ...` command output at the end.
* **Setup kubectl:** Run the 3 commands displayed in the output (mkdir, cp, chown) to use `kubectl` as a regular user.
* **Install Network Plugin (Calico):**
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

```



**Step 3: Join the Worker Node**
Open a new terminal tab (keep the control plane open) and SSH into the worker:

```bash
vagrant ssh node01

```

Paste the `sudo kubeadm join ...` command you copied from Step 2.

**Step 4: Verify**
Back on the **controlplane**, check your nodes:

```bash
kubectl get nodes

```

You should see `controlplane` and `node01` change to `Ready` status within a minute.

---

**Recommended Video:**
... [How to install a cluster on Ubuntu with kubeadm](https://www.youtube.com/watch?v=wIZamzt7MkM) ...
This video walks through the exact `kubeadm` installation process on Ubuntu, which is useful if you encounter errors during the initialization step.