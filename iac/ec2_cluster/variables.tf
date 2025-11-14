variable "cluster_name" {
  description = "Name of the Kubernetes cluster."
  type        = string
}

variable "cluster_token" {
  description = "Pre-shared token for RKE2 cluster nodes"
  type        = string
  sensitive   = true
}

variable "master_count" {
  description = "Number of EC2 instances (master node) to provision (1 to 5)."
  type        = number
}

variable "master_instance" {
  description = "EC2 instance type for master node."
  type        = string
}

variable "master_root_size" {
  description = "Root volume size in GB"
  type        = number
}

variable "worker_count" {
  description = "Number of EC2 instances (worker node) to provision."
  type        = number
}

variable "worker_instance" {
  description = "EC2 instance type for worker node."
  type        = string
}

variable "worker_root_size" {
  description = "Root volume size in GB"
  type        = number
}

variable "pub_key_path" {
  description = "Path to SSH public key."
  type        = string
}

variable "rke2_version" {
  description = "Install the specified RKE2 version."
  type        = string
}
