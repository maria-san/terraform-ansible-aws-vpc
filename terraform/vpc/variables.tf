variable "project" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "AWS Region to use"
  type        = string
}

variable "vpc_name" {
  description = "Name to give the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "Primary CIDR of VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
  default     = {}
}