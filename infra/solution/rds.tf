# ---------------------------------------------------------------
# RDS PostgreSQL — instancia única del sistema
# database: surveillance (brokerage vive en instancia separada del cliente)
# db.t4g.small | gp3 20 GB | Ohio | single-AZ
# ---------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier     = "market-surveillance"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.small"

  db_name  = "surveillance"
  username = var.db_username
  password = var.db_password

  allocated_storage     = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 1

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = {
    Project = "market-surveillance"
  }
}
