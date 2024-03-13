
output "lb_service_name_orders" {
  value       = local.lb_service_name_orders
  description = "Name of the Load Balancer K8s service that exposes orders microservice"
}

output "lb_service_port_orders" {
  value       = local.lb_service_port_orders
  description = "Port exposed of the Load Balancer K8s service associated to orders micorservice"
}


output "lb_service_name_production" {
  value       = local.lb_service_name_production
  description = "Name of the Load Balancer K8s service that exposes production microservice"
}

output "lb_service_port_production" {
  value       = local.lb_service_port_production
  description = "Port exposed of the Load Balancer K8s service associated to production micorservice"
}
