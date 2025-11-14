terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
  encryption {
    key_provider "pbkdf2" "passphrase" {
      passphrase = var.tf_passphrase
    }
  }
}
