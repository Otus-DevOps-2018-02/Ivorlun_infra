terraform {
  backend "gcs" {
    bucket = "terraform_backend"
    prefix = "terraform/state"
  }
}
