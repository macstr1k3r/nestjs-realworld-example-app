terraform {
  required_version = ">= 0.14.0"

  required_providers {
    aws-us = {
      source  = "hashicorp/aws"
      version = "~> 3.20"
    }
  }
}
