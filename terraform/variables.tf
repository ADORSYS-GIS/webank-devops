# Variables for database credentials
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "webank"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  default     = "webank123"
}

variable "name" {
  description = "Name prefix to be used for resources"
  type        = string
}

variable "azs" {
  description = "Name prefix to be used for resources"
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ec2_instance" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance" {
  description = "DB instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.55.0.0/16"
}

variable "db_backup_retention_period" {
  description = "Environment"
  type        = string
  default     = null
}