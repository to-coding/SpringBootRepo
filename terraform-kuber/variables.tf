variable "region" {
  description = "region"
  type = string
  default = "us-east-1"
}
variable "deployment_name" {
  description = "project name for deploy"
  type        = string
  default     = "beach-deployment"
}

variable "project_label" {
  description = "app label"
  type        = string
  default     = "java-demo"
}

variable "container_name" {
  description = "spec container name"
  type        = string
  default     = "java-beach-container"
}

variable "repository_name" {
  description = "ECR repository created in terraform-eks-cluster"
  type        = string
  default     = "beach_ecr"
}

variable "container_port" {
  description = "open port in container"
  type        = number
  default     = 8080
}

variable "service_name" {
  description = "java service name"
  type        = string
  default     = "java-onbeach-service"
}
variable "aws_account_id" {
  description = "account id"
  type = string
  default = "160071257600"
}
