output "elb_dns_name" {
  value       = aws_lb.ecommerce.dns_name
  description = "DNS del Load Balancer público"
}

output "elb_arn" {
  value       = aws_lb.ecommerce.arn
  description = "ARN del Load Balancer"
}

output "elb_listener_http_arn" {
  value       = aws_lb_listener.http.arn
  description = "ARN del listener HTTP"
}

#output "elb_listener_https_arn" {
#  value       = aws_lb_listener.https.arn
#  description = "ARN del listener HTTPS"
#}

output "target_group_web_arn" {
  value       = aws_lb_target_group.web.arn
  description = "ARN del target group de la aplicación web"
}
