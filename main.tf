terraform {
  backend "local" {
    
  }

  # backend "s3" {
  #   bucket         = "terraform-vpc-terraform-config"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "ap-southeast-1"
  # }
}

data "aws_availability_zones" "available" {
}

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-vpc-terraform-config"
#   acl    = "private"

#   # Enable versioning so we can see the full revision history of our
#   # state files
#   versioning {
#     enabled = true
#   }

#   # Enable server-side encryption by default
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }

#   tags = {
#     Name        = "terraform-vpc-terraform-config"
#     Environment = var.environment
#   }
# }



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"
  # insert the 14 required variables here
  
  name = var.project_name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  depends_on = [ 
    module.vpc.vpc_id
  ]

  tags = {
    Environment = var.environment
    ProjectName  = var.project_name
  }

  vpc_id = module.vpc.vpc_id

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

