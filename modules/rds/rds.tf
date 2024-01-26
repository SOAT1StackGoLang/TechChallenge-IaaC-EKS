resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = var.database_subnetids
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  vpc_id      = var.vpc_id
  description = "Allow all inbound for Postgress"

  ingress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "techchallenge-rds"
  db_name                = var.database_name
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  username               = var.database_username
  password               = var.database_password
  port                   = var.database_port
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  availability_zone      = var.availability_zone
  multi_az               = false
}

