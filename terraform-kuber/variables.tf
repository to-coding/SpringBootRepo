variable "deployment_name" {
  description = "project name for deploy"
  type = string
  default = "beach-deployment"
}

variable "project_label" {
  description = "app label"
  type = string
  default = "java-demo"
}

variable "container_name" {
  description = "spec container name"
  type = string
  default = "java-beach-container"
}

variable "container_image_name" {
  description = "the image need to deploy(ECR or dockerhub url)"
  type = string
  default = "demo"
}
variable "container_image_tag" {
  description = "version of image"
  type = string
  default = "latest"
}

variable "container_port" {
  description = "open port in container"
  type = number
  default = 8080
}

variable "service_name" {
  description = "java service name"
  type = string
  default = "java-onbeach-service"
}
