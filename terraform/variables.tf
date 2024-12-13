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
  default     = "12.34.0.0/16"
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

variable "db_instance" {
  description = "The instance type for the RDS database"
  type        = string
  default     = "db.t3.medium"
}

variable "environment" {
  description = "The environment to deploy resources to"
  type        = string
  default     = "staging"
}

variable "eks_ec2_instance_types" {
  description = "The EC2 instance type for the Jenkins server"
  type = list(string)
  default = ["t2.medium"]
}

variable "eks_min_instance" {
  description = "The minimum number of instances for the EKS cluster"
  type        = number
  default     = 1
}

variable "eks_max_instance" {
  description = "The maximum number of instances for the EKS cluster"
  type        = number
  default     = 3
}

variable "eks_desired_instance" {
  description = "The desired number of instances for the EKS cluster"
  type        = number
  default     = 2
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = null
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS database"
  type        = bool
  default     = true
}

variable "zone_name" {
  description = "The name of the Route 53 zone"
  type        = string
  default     = "apple.banana.miaou"
}

variable "cert_arn" {
  description = "The ARN of the SSL certificate"
  type        = string
}

variable "oidc_kc_client_id" {
  description = "The client ID for the OIDC provider"
  type        = string
}

variable "oidc_kc_client_secret" {
  description = "The client secret for the OIDC provider"
  type        = string
}

variable "oidc_kc_issuer_url" {
  description = "The issuer URL for the OIDC provider"
  type        = string
}