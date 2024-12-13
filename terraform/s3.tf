module "terraform_state_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "1.5.0"

  namespace = "webank"
  stage     = "dev"
  name      = "terraform"

  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false

}