resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "postgresql_subnet_group" {
  name       = "postgresql-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "PostgreSQL subnet group"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier        = "${var.name}-db"
  engine            = "postgres"
  engine_version    = "17.2"
  instance_class    = "db.t3.medium"
  allocated_storage = 10
  db_name           = "prodclusterdb"
  username          = var.db_username
  password          = var.db_password
  publicly_accessible = false

  family            = "postgres17"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.postgresql_subnet_group.name
  storage_encrypted     = true
  backup_retention_period = 7
}
