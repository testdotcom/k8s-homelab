variable "passphrase" {
  description = "Terraform state encryption key."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster."
  type        = string
}

variable "cluster_token" {
  description = "Pre-shared token for RKE2 cluster nodes"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.cluster_token) >= 16
    error_message = "Cluster token must be at least 16 characters long."
  }
}

variable "master_count" {
  description = "Number of EC2 instances (master node) to provision (1 to 5)."
  type        = number
  default     = 1

  validation {
    condition     = var.master_count >= 1 && var.master_count <= 5
    error_message = "You must specify between 1 and 5 instances."
  }
}

variable "master_instance" {
  description = "EC2 instance type for master node."
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 40
}

variable "pub_key_path" {
  description = "Path to SSH public key."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "rke2_version" {
  description = "Install the specified RKE2 version."
  type = string
  default = "v1.34.1+rke2r1"
}
