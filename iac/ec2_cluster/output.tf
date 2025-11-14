output "cluster_info" {
  description = "Cluster name, EC2 instance IDs"
  value = {
    name : var.cluster_name
    master_ids : aws_instance.k8s_master[*].id
    worker_ids : aws_instance.k8s_worker[*].id
  }
}
