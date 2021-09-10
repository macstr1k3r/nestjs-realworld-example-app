terraform {
  backend "s3" {
    bucket  = "nrw-terraform-backend"
    key     = "nrw-ecr"
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

