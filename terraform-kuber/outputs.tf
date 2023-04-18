output "load_balancer_hostname" {
    value = kubernetes_service.java.status.0.load_balancer.0.ingress.0.hostname
}

output "deployment_name" {
    value = kubernetes_deployment.java.metadata.name
}

