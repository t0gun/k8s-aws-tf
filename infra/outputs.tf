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