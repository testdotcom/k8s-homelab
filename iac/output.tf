output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.k8s_master[*].id
}

output "cluster_info" {
  description = "Cluster information summary"
  value = {
    cluster_name   = var.cluster_name
    instance_count = var.master_count
    instance_type  = var.master_instance
  }
}
