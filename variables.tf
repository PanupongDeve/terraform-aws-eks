variable "project_name" {
  default = "terraform-eks-vpc"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "environment" {
  default = "dev"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "xxxxxxxxxxxxx"
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::xxxxxxxxxxxxx:role/eksServiceRole"
      username = "eksServiceRole"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::xxxxxxxxxxxxx:user/panupong"
      username = "panupong"
      groups   = ["system:masters"]
    },
  ]
}

locals {
  cluster_name = "${var.project_name}-eks-cluster"
}