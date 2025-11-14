resource "random_pet" "cluster_name" {
  prefix = "rke2-cluster"
}

resource "random_password" "cluster_token" {
  length  = 32
  special = false
  upper   = false
}

module "ec2_cluster" {
  source = "${path.module}/ec2_cluster"

  cluster_name  = random_pet.cluster_name.id
  cluster_token = random_password.cluster_token.result

  master_count     = var.master_count
  master_instance  = var.master_instance
  master_root_size = var.master_root_size

  worker_count     = var.worker_count
  worker_instance  = var.worker_instance
  worker_root_size = var.worker_root_size

  pub_key_path = var.pub_key_path
  rke2_version = var.rke2_version
}
