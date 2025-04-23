resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.environment}-ecommerce-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"
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
  vpc_id = var.vpc_id
  name   = "${var.environment}-rds-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
}