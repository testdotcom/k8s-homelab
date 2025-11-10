terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
  encryption {
    key_provider "pbkdf2" "passphrase" {
      passphrase = var.passphrase
    }
  }
}

provider "aws" {

}
