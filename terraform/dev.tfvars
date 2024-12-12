vpc_cidr                   = "12.34.0.0/16"
environment                = "dev"
eks_min_instance           = 1
eks_max_instance           = 3
eks_desired_instance       = 2
db_instance                = "db.t3.medium"
db_backup_retention_period = null
db_skip_final_snapshot     = true
eks_ec2_instance_types = [
  "t2.nano",
  "t2.medium",
  "t2.large"
]
azs = [
  "eu-central-1a",
  "eu-central-1b",
  "eu-central-1c"
]