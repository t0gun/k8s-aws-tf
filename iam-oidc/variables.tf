variable "region" {
  type = string
  default = "ca-central-1"
}

variable "github_repo" {
  type = string
  default = "t0gun/k8s-aws-tf"
}

variable "allowed_refs" {
  type = list(string)
  default = ["refs/heads/main"]
}


variable "state_bucket" {
  type = string
  default = "tf-state-prod-555066115752"
}