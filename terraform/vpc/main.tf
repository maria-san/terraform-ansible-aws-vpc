provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

locals {
  azs            = split(",", var.azs)
  vpc_name       = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  tags = {
    "Project" : var.project
  }
}
