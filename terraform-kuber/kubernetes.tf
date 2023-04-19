terraform {
    cloud {
        organization = "example-org-b53b57"

        workspaces {
            name = "terraform-kuber"
        }
    }
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.63.0"
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

data "aws_ecr_image" "service_image" {
    repository_name = var.container_image_name
    image_tag       = var.container_image_tag
}

resource "kubernetes_deployment" "java" {
    metadata {
        name   = var.deployment_name
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
                    image = data.aws_ecr_image
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
