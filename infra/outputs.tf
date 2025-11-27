output "kthw_instance_ids" {
  value = {
    server = aws_instance.server.id
    node_0 = aws_instance.node_0.id
    node_1 = aws_instance.node_1.id
  }
}

output "kthw_private_ips" {
  value = {
    server = aws_instance.server.private_ip
    node_0 = aws_instance.node_0.private_ip
    node_1 = aws_instance.node_1.private_ip
  }
}

output "machines_txt" {
  description = "Ready-to-paste machines.txt for KTHW"
  value = <<EOT
${aws_instance.server.private_ip}  server.kubernetes.local  server  10.200.0.0/24
${aws_instance.node_0.private_ip} node-0.kubernetes.local  node-0  10.200.1.0/24
${aws_instance.node_1.private_ip} node-1.kubernetes.local  node-1  10.200.2.0/24
EOT
}