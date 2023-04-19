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
            version = "~> 4.63.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.16.1"
        }
        tls = {
            source  = "hashicorp/tls"
            version = "~> 4.0.4"
        }
        cloudinit = {
            source  = "hashicorp/cloudinit"
            version = "~> 2.3.2"
        }
    }
    required_version = "~> 1.3"
}
