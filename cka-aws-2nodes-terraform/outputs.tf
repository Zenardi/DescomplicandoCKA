output "instance_public_ips" { value = [for i in aws_instance.nodes : i.public_ip] }
output "instance_private_ips" { value = [for i in aws_instance.nodes : i.private_ip] }
output "ssh_examples" { value = [for i in aws_instance.nodes : "ssh -i <key.pem> ubuntu@${i.public_ip}"] }
