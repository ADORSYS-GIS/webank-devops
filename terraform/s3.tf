terraform {
  backend "s3" {
    key            = "terraform.tfstate"
    encrypt        = true
  }
}