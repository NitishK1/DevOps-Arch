# Primary Region Outputs
output "primary_region" {
  description = "Primary AWS region"
  value       = var.primary_region
}

output "primary_alb_dns" {
  description = "Primary region ALB DNS name"
  value       = module.primary_ecs.alb_dns_name
}

output "primary_alb_url" {
  description = "Primary region application URL"
  value       = "http://${module.primary_ecs.alb_dns_name}"
}

output "primary_ecr_repository" {
  description = "Primary ECR repository URL"
  value       = module.primary_ecr.repository_url
}

output "primary_codecommit_clone_url" {
  description = "Primary CodeCommit clone URL"
  value       = module.primary_codecommit.clone_url_http
}

output "primary_ecs_cluster" {
  description = "Primary ECS cluster name"
  value       = module.primary_ecs.cluster_name
}

output "primary_cloudwatch_dashboard" {
  description = "Primary CloudWatch dashboard name"
  value       = module.primary_monitoring.dashboard_name
}

# Secondary Region Outputs
output "secondary_region" {
  description = "Secondary AWS region"
  value       = var.secondary_region
}

output "secondary_alb_dns" {
  description = "Secondary region ALB DNS name"
  value       = module.secondary_ecs.alb_dns_name
}

output "secondary_alb_url" {
  description = "Secondary region application URL"
  value       = "http://${module.secondary_ecs.alb_dns_name}"
}

output "secondary_ecr_repository" {
  description = "Secondary ECR repository URL"
  value       = module.secondary_ecr.repository_url
}

output "secondary_codecommit_clone_url" {
  description = "Secondary CodeCommit clone URL"
  value       = module.secondary_codecommit.clone_url_http
}

output "secondary_ecs_cluster" {
  description = "Secondary ECS cluster name"
  value       = module.secondary_ecs.cluster_name
}

# General Outputs
output "deployment_summary" {
  description = "Deployment summary"
  value = <<-EOT

  ╔═══════════════════════════════════════════════════════════════════════════╗
  ║                    AWS DevOps Multi-Region Deployment                      ║
  ║                              Deployment Complete!                           ║
  ╚═══════════════════════════════════════════════════════════════════════════╝

  PRIMARY REGION (${var.primary_region}):
  ├─ Application URL: http://${module.primary_ecs.alb_dns_name}
  ├─ ECS Cluster: ${module.primary_ecs.cluster_name}
  ├─ ECR Repository: ${module.primary_ecr.repository_url}
  ├─ CodeCommit Repo: ${module.primary_codecommit.clone_url_http}
  └─ CloudWatch Dashboard: ${module.primary_monitoring.dashboard_name}

  SECONDARY REGION (${var.secondary_region}):
  ├─ Application URL: http://${module.secondary_ecs.alb_dns_name}
  ├─ ECS Cluster: ${module.secondary_ecs.cluster_name}
  ├─ ECR Repository: ${module.secondary_ecr.repository_url}
  ├─ CodeCommit Repo: ${module.secondary_codecommit.clone_url_http}
  └─ CloudWatch Dashboard: ${module.secondary_monitoring.dashboard_name}

  NEXT STEPS:
  1. Confirm SNS subscription email (check your inbox)
  2. Push your application code to CodeCommit
  3. Monitor the CI/CD pipeline in AWS Console
  4. Access your application using the URLs above

  For cleanup: ./scripts/cleanup.sh

  EOT
}
