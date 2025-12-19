output "repository_id" {
  description = "CodeCommit repository ID"
  value       = aws_codecommit_repository.main.repository_id
}

output "repository_name" {
  description = "CodeCommit repository name"
  value       = aws_codecommit_repository.main.repository_name
}

output "clone_url_http" {
  description = "CodeCommit clone URL (HTTP)"
  value       = aws_codecommit_repository.main.clone_url_http
}

output "clone_url_ssh" {
  description = "CodeCommit clone URL (SSH)"
  value       = aws_codecommit_repository.main.clone_url_ssh
}

output "arn" {
  description = "CodeCommit repository ARN"
  value       = aws_codecommit_repository.main.arn
}
