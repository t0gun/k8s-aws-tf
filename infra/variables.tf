variable "region" {
  type = string
  default = "ca-central-1"
}

variable "instance_type" {
  description = "EC2 instance type for all KTHW nodes"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size_gb" {
  description = "Root volume size for KTHW nodes"
  type        = number
  default     = 20
}