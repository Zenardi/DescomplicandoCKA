
# CKA Practice Lab — 2 Ubuntu 22.04 Nodes

You have two clean Ubuntu 22.04 servers to practice installing Kubernetes using kubeadm.

Nothing is pre-installed.

## Requirements

- AWS credentials configured
- Existing EC2 Key Pair
- Terraform installed

## Create terraform.tfvars

aws_region   = "us-east-1"
name_prefix  = "cka-yourname"
vpc_id       = "vpc-xxxx"
subnet_id    = "subnet-xxxx"
key_name     = "your-keypair"
allowed_cidr = "YOUR_IP/32"

## Create the machines

terraform init
terraform apply

## SSH access

ssh -i your-key.pem ubuntu@PUBLIC_IP

## Your tasks

On BOTH nodes:

- Disable swap
- Install containerd
- Install kubeadm, kubelet, kubectl
- Configure sysctl and kernel modules

On the FIRST node:

- kubeadm init
- Install a CNI

On the SECOND node:

- kubeadm join

## Destroy when finished

terraform destroy
