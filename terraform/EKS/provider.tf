terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  cloud {
    organization = "hyq"

    workspaces {
      name = "hyq-workspace"
    }
  }
}
