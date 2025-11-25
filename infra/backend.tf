terraform {
  backend "s3" {
    bucket       = "tf-state-prod-555066115752"
    key          = "prod/k8-aws-tf/terraform.tfstate"
    region       =  "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
