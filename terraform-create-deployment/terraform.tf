# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    #    cloudinit = {
    #      source  = "hashicorp/cloudinit"
    #      version = "~> 2.2.0"
    #    }
  }
  cloud {
    organization = "example-org-512516"

    workspaces {
      name = "terraform-deployment"
    }
  }

  required_version = "~> 1.3"
}