terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "example-org-512516"
    workspaces = {
      name = "learn-terraform-github-actions"
    }
  }
}

# Retrieve EKS cluster information
provider "aws" {
  region = var.region
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

resource "kubernetes_deployment" "newest-springboot" {
  metadata {
    name = "scalable-springboot-example"
    labels = {
      App = "ScalableSpringBootExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableSpringBootExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableSpringBootExample"
        }
      }
      spec {
        container {
          image = "baosh/clockbox"
          name  = "baosh"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "newest-springboot" {
  metadata {
    name = "springboot-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.newest-springboot.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}


output "lb_ip" {
  value = kubernetes_service.newest-springboot.status.0.load_balancer.0.ingress.0.hostname
}

