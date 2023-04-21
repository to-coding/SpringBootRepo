data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "hyq"

    workspaces = {
      name = "hyq-workspace"
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
    args        = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

resource "kubernetes_deployment" "demo" {
  metadata {
    name   = "hyq-beach-app"
    labels = {
      App = "demoApp"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "demoApp"
      }
    }
    template {
      metadata {
        labels = {
          App = "demoApp"
        }
      }
      spec {
        container {
          image = "160071257600.dkr.ecr.ap-southeast-2.amazonaws.com/beach-hyq:latest"
          name  = "example"

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

resource "kubernetes_service" "demo" {
  metadata {
    name = "java-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.demo.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
