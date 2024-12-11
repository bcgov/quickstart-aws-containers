variable "target_env" {
  description = "AWS workload account env"
  type        = string
}

variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
}

variable "db_cluster_name" {
  description = "Name for the database cluster -- must be unique"
  type        = string
  
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


