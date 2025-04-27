data "terraform_remote_state" "infra_output" {
  backend  = "gcs"
  config = {
    bucket   = var.bucket_name
    prefix   = "${var.bucket_prefix}/terraform.tfstate"
  }
}