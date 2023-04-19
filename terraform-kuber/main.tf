provider "aws" {
  region = "us-east-1"
}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "example-org-b53b57"
    workspaces = {
      name = "workspace01"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}
resource "kubernetes_deployment" "java" {
  metadata {
    name = var.deployment_name
    labels = {
      app = var.project_label
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = var.project_label
      }
    }
    template {
      metadata {
        labels = {
          app = var.project_label
        }
      }
      spec {
        container {
          image = "160071257600.dkr.ecr.us-east-1.amazonaws.com/beach_ecr:latest"
          name  = var.container_name
          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "java" {
  depends_on = [kubernetes_deployment.java]
  metadata {
    name = var.service_name
  }
  spec {
    selector = {
      app = var.project_label
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
