terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_codecommit_repository" "main" {
  repository_name = "${var.project_name}-repo"
  description     = "Repository for ${var.project_name} application"

  tags = {
    Name = "${var.project_name}-repo"
  }
}
