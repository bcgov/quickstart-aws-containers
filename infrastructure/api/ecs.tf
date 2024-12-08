data "aws_secretsmanager_secret" "db_master_creds" {
  name = "db-master-creds-${var.target_env}"
}



data "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "qsawsc-aurora-cluster-${var.target_env}"
}

data "aws_secretsmanager_secret_version" "db_master_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_master_creds.id
}

locals {
  db_master_creds = jsondecode(data.aws_secretsmanager_secret_version.db_master_creds_version.secret_string)
}

output "db_master_creds_string" {
  value = local.db_master_creds
  sensitive = true
}
output "database_endpoint" {
  value = data.aws_rds_cluster.rds_cluster.endpoint
}