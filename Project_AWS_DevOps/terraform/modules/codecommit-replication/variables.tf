variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "source_region" {
  description = "Source region (primary)"
  type        = string
}

variable "destination_region" {
  description = "Destination region (secondary)"
  type        = string
}

variable "source_repository_name" {
  description = "Name of the source CodeCommit repository"
  type        = string
}

variable "destination_repository_name" {
  description = "Name of the destination CodeCommit repository"
  type        = string
}

variable "source_repository_arn" {
  description = "ARN of the source CodeCommit repository"
  type        = string
}

variable "destination_repository_arn" {
  description = "ARN of the destination CodeCommit repository"
  type        = string
}
