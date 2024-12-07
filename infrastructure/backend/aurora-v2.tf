data "aws_kms_alias" "rds_key" {
  name = "alias/aws/rds"
}

locals {
    aws_security_group_data_sg_id = "${aws_security_group.data_sg.id}"
}

resource "random_password" "db_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

variable "db_master_username" {
  description = "The username for the DB master user"
  type        = string
  default     = "sysadmin"
  sensitive   = true
}

variable "db_database_name" {
  description = "The name of the database"
  type        = string
  default     = "app"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  description = "For Aurora cluster ${var.db_cluster_name}"
  name        = "${var.db_cluster_name}-subnet-group"
  subnet_ids  = [data.aws_subnet.a_data.id, data.aws_subnet.b_data.id]

  tags = {
    managed-by = "terraform"
  }

  tags_all = {
    managed-by = "terraform"
  }
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "16.4"
}

resource "aws_db_parameter_group" "db_postgresql" {
  name        = "${var.db_cluster_name}-parameter-group"
  family      = "aurora-postgresql16"
  description = "${var.db_cluster_name}-parameter-group"
  tags = {
    managed-by = "terraform"
  }
}

resource "aws_rds_cluster_parameter_group" "db_postgresql" {
  name        = "${var.db_cluster_name}-cluster-parameter-group"
  family      = "aurora-postgresql16"
  description = "${var.db_cluster_name}-cluster-parameter-group"
  tags = {
    managed-by = "terraform"
  }
}

resource "random_pet" "master_creds_secret_name" {
  prefix = "db-master-creds"
  length = 2
}

resource "aws_secretsmanager_secret" "db_mastercreds_secret" {
  name = random_pet.master_creds_secret_name.id

  tags = {
    managed-by = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_mastercreds_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_mastercreds_secret.id
  secret_string = <<EOF
   {
    "username": "${var.db_master_username}",
    "password": "${random_password.db_master_password.result}"
   }
EOF
}
module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "9.10.0"

  name              = var.db_cluster_name
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "serverless"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  database_name     = var.db_database_name

  vpc_id                 = data.aws_vpc.selected.id
  vpc_security_group_ids = [local.aws_security_group_data_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  master_username = var.db_master_username
  master_password = random_password.db_master_password.result

  
  create_security_group  = false
  create_db_subnet_group = false
  create_monitoring_role = false
  
  apply_immediately   = true
  skip_final_snapshot = true
  auto_minor_version_upgrade = false

  db_parameter_group_name         = aws_db_parameter_group.db_postgresql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_postgresql.id

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }

  tags = {
    managed-by = "terraform"
  }

  enabled_cloudwatch_logs_exports = ["postgresql"]
}


