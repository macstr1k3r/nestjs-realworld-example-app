terraform {
  backend "s3" {
    bucket  = "nrw-terraform-backend"
    key     = "nrw-app"
    region  = "us-east-1"
    encrypt = true

    dynamodb_table = "terraform-lock"
  }

  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}


locals {
  tags = {
    env = {
      "nrw:env" : terraform.workspace
    }
  }
}

variable "base_domain" {
  type = string
}

variable "network_cidr_block" {
  type = string
}