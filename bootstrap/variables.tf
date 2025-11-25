variable "region" {
  type = string
  default = "ca-central-1"
  description = "region where provisioning happens"
}

variable "state_bucket" {
  type = string
  default = "tf-state-prod-555066115752"
  description = "the name of the bucket to be created in S3"
}