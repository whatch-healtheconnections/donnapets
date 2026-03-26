terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "donnaspersonalpetcare-tf-state"
    key    = "static-site/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# ACM certs for CloudFront MUST live in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
