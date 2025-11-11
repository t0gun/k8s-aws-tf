[![Terraform CI](https://github.com/t0gun/kthw-aws-terraform/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/t0gun/kthw-aws-terraform/actions/workflows/terraform.yml)      
# Kubernetes the Hard Way Infrastructure Automation
This repo provisions the AWS network and compute needed to help  run [Kelsey Hightower’s *Kubernetes The Hard
Way*](https://github.com/kelseyhightower/kubernetes-the-hard-way). It only spins up the infrastructure and does not
install the cluster or any packages.

## What this repo provisions

- Single-AZ VPC with one public subnet and one private subnet
- Internet Gateway for public egress
- Elastic IP and NAT Gateway for private egress
- Public and private route tables with associations
- Private security group: SSH only from bastion, intra-SG allowed, egress on ports 80 and 443
- Bastion EC2 (Ubuntu 24.04) in the public subnet with a public IP and SSM agent via `user_data`
- Four Debian 12 (Bookworm) EC2 instances in the private subnet with SSH access from the bastion only
- IAM role and instance profile for SSM attached to the bastion
- Key pair created from your public key, read from GitHub Secrets
- Remote Terraform state in S3 with DynamoDB locking
- GitHub Actions workflow for manual plan, apply, and destroy
- Terraform outputs saved as an artifact and summarized in the run

## Security posture

| Group      | Ingress                            | Egress                            |
|------------|------------------------------------|-----------------------------------|
| bastion-sg | SSH 22 from `allowed_ssh_cidrs`    | 80/443 to internet; SSH 22 to VPC |
| private-sg | SSH 22 from `bastion-sg`; intra-SG | 80/443 to internet and ICMP       |

## Architecture
![KTHW AWS architecture (single-AZ VPC, bastion, private Debian nodes)](docs/tf-kthwdrawio.png)



[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

