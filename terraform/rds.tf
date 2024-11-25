module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.name}-sg"
  description = "Complete PostgreSQL example security group"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = merge(
    local.tags,
    {}
  )
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier          = "${var.name}-db"
  engine              = "postgres"
  engine_version      = "17.2"
  instance_class      = "db.t3.medium"
  allocated_storage   = 10
  db_name             = var.name
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = false

  family = "postgres17"

  vpc_security_group_ids = [module.security_group.security_group_id]
  db_subnet_group_name    = module.vpc.database_subnet_group
  storage_encrypted       = true
  backup_retention_period = 7
}