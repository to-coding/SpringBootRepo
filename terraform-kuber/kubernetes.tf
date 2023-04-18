terraform {
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
    backend = "local"

    config = {
        path = "/Users/gaoxiang.huang/K8S/learn-terraform-provision-eks-cluster/terraform.tfstate"
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

#resource "null_resource" "java" {
#    depends_on = [module.eks]
#    provisioner "local-exec" {
#        command     = "aws eks --region us-east-1  update-kubeconfig --name $AWS_CLUSTER_NAME"
#        environment = {
#            AWS_CLUSTER_NAME = local.cluster_name
#        }
#    }
#}

resource "kubernetes_deployment" "java" {
    metadata {
        name   = "microservice-deployment"
        labels = {
            app = "java-microservice"
        }
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "java-microservice"
            }
        }
        template {
            metadata {
                labels = {
                    app = "java-microservice"
                }
            }
            spec {
                container {
                    image = "160071257600.dkr.ecr.us-east-1.amazonaws.com/oneapptest:latest"
                    name  = "java-microservice-container"
                    port {
                        container_port = 8080
                    }
                }
            }
        }
    }
}
resource "kubernetes_service" "java" {
    depends_on = [kubernetes_deployment.java]
    metadata {
        name = "java-microservice-service"
    }
    spec {
        selector = {
            app = "java-microservice"
        }
        port {
            port        = 80
            target_port = 8080
        }
        type = "LoadBalancer"
    }
}
