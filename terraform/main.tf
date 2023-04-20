# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
  access_key = "ASIASKRH5RYAK6DP2KHI"
  secret_key = "tpysmwN2NF32boAsuceki374pp3eUcF4zvIaDnHV"
  token = "IQoJb3JpZ2luX2VjEIv//////////wEaDGV1LWNlbnRyYWwtMSJGMEQCIDdowASeaJCEsATtjeLRH3BbahSlFrtiVWopYG58bb54AiBd5zLaczQZ49svwxanSXgqcQfF7pbajpMrLPluV7wYuCqjAwiE//////////8BEAQaDDE2MDA3MTI1NzYwMCIMLFcu+1gm8AkTx6JTKvcCTcJrw9AsIYtBy/suHQcVDGr51AFYU3fXjfYyXRLH0/xpyOxDbiJmRPkt5TEPcv7XyiVxet62qOyMDEJECGo5XMYkKwO/r9qdyysfkyrChogYbw1xKeU1YnmuzCc1Xai3xL3bv9hg1BKsH6eUQiYarGt5iiBqVwauSxOTCVqgtFpUPIs9HGvACDhJtoHWq4/IRnwf2xIdJaGao1i3zAtY34Ges5XCTxCSyP7SgDYhEI2Bo3YwyJqf8xAIwI8ikrIT9PyucoVOTsnd+lujtNoOs7U8gdnZm/vspXrkuWprpek/FApTHaondpec7f4ZDC37KwRV+GwdVer3qA9VleGM37hSAp9TpIty3oXqdQjC5YcrSXJrMxyMg600OWu8t/eLgQ8IlKcnFwvdxeQTiygLSu7+i1nxI6moG7gCHD9pgZUU0oUxHIumjHnUSjVdiN8c4ZWBC5pT5jojpLBh+IwIhUK+HKaYIZwXjWAymsSGsbcVXeX+tUB2MLzagqIGOqcBmxqShKO8XduUqv6xywJOVmy28xGn1jb2EL9WQb82g2nnW8tQqMVL56V/v3TngmlCV4+WymPERpwTGh/vPWyVUNm2n1+JVdnjejrjMeLoI2wRbAOvYNcQmGxZWoSXj3WE5I1oOZmCE/7yh30EEmIzGHXx76BuxQA+D0e26VYRZfEA9LGqRUvY2wYuYOJ9/T54NtZdHBRTyDrlEDnZwtoNmu5Lmoc+7uA="
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "new-education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "new-education-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

