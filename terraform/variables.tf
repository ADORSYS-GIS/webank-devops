variable "region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "eu-west-1"
}

variable "name" {
  description = "The name of the cluster"
  type        = string
  default     = "webank-cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.123.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the VPC"
  type = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "The environment to deploy resources to"
  type        = string
  default     = "dev"
}