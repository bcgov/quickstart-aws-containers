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
  flyway_image=${local.flyway_image}
  api_image=${local.api_image}
  app_env=${local.app_env}
EOF
}