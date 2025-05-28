resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.environment}-ecommerce-cluster"
  engine                  = "postgres"
  engine_version          = "PostgreSQL 17.2-R2"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = true
  deletion_protection     = false
}

resource "aws_rds_cluster_instance" "instances" {
  count              = var.multi_az ? 2 : 1
  identifier         = "${var.environment}-ecommerce-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "rds" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-rds-sg"
  description = "Allow PostgreSQL access from EC2 instances only"

  ingress {
    description              = "PostgreSQL access from EC2 instances"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups          = [var.ec2_security_group_id]
  # Asegura que solo EC2 con este SG puedan conectarse
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-rds-sg" }
}
