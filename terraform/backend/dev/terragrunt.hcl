include {
  path = find_in_parent_folders()
}

# Include the common terragrunt configuration for all modules
generate "dev_tfvars" {
  path              = "dev.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
  target_env = "dev"
  db_cluster_name = "qsawsc-aurora-cluster-dev"
EOF
}