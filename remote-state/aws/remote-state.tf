data "terraform_remote_state" "infra_output" {
  backend  = "s3"
  config = {
    bucket  = var.bucket_name
    key     = "${var.bucket_prefix}/terraform.tfstate"
    profile = var.provider_id
    region  = var.location
    encrypt = true
  }
}