[![Terraform CI](https://github.com/t0gun/kthw-aws-terraform/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/t0gun/kthw-aws-terraform/actions/workflows/terraform.yml)

# Kubernetes the Hard Way Infrastructure Automation

This repo provisions the AWS network and compute needed to run [Kelsey Hightower’s *Kubernetes The Hard
Way*](https://github.com/kelseyhightower/kubernetes-the-hard-way). It only spins up the infrastructure and does not
install the cluster or any packages.

my previous setup using bastion, NAT gateway, public and private subnet but i have decided to make it minimal. i use a
single private subnet with no NAT, NO SSH and VPC endpoints for internal AWS connectivity. modified re

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

