terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary Region Provider
provider "aws" {
  region = var.primary_region
  alias  = "primary"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# Secondary Region Provider
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# Primary Region Infrastructure
module "primary_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
  region       = var.primary_region
  vpc_cidr     = var.primary_vpc_cidr
  azs          = var.primary_azs
}

module "primary_ecr" {
  source = "./modules/ecr"
  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
}

module "primary_ecs" {
  source = "./modules/ecs"
  providers = {
    aws = aws.primary
  }

  project_name        = var.project_name
  environment         = var.environment
  region              = var.primary_region
  vpc_id              = module.primary_vpc.vpc_id
  public_subnets      = module.primary_vpc.public_subnets
  private_subnets     = module.primary_vpc.private_subnets
  ecr_repository_url  = module.primary_ecr.repository_url
  container_image     = "${module.primary_ecr.repository_url}:latest"
}

module "primary_codecommit" {
  source = "./modules/codecommit"
  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
}

module "primary_codepipeline" {
  source = "./modules/codepipeline"
  providers = {
    aws = aws.primary
  }

  project_name          = var.project_name
  environment           = var.environment
  region                = var.primary_region
  repository_name       = module.primary_codecommit.repository_name
  ecr_repository_name   = module.primary_ecr.repository_name
  ecr_repository_url    = module.primary_ecr.repository_url
  ecs_cluster_name      = module.primary_ecs.cluster_name
  ecs_service_name      = module.primary_ecs.service_name
  notification_email    = var.notification_email
}

module "primary_monitoring" {
  source = "./modules/monitoring"
  providers = {
    aws = aws.primary
  }

  project_name        = var.project_name
  environment         = var.environment
  region              = var.primary_region
  ecs_cluster_name    = module.primary_ecs.cluster_name
  ecs_service_name    = module.primary_ecs.service_name
  alb_arn_suffix      = module.primary_ecs.alb_arn_suffix
  target_group_arn_suffix = module.primary_ecs.target_group_arn_suffix
  log_group_name      = module.primary_ecs.log_group_name
  notification_email  = var.notification_email
}

# Secondary Region Infrastructure
module "secondary_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.secondary
  }

  project_name = var.project_name
  environment  = var.environment
  region       = var.secondary_region
  vpc_cidr     = var.secondary_vpc_cidr
  azs          = var.secondary_azs
}

module "secondary_ecr" {
  source = "./modules/ecr"
  providers = {
    aws = aws.secondary
  }

  project_name = var.project_name
  environment  = var.environment
}

module "secondary_ecs" {
  source = "./modules/ecs"
  providers = {
    aws = aws.secondary
  }

  project_name        = var.project_name
  environment         = var.environment
  region              = var.secondary_region
  vpc_id              = module.secondary_vpc.vpc_id
  public_subnets      = module.secondary_vpc.public_subnets
  private_subnets     = module.secondary_vpc.private_subnets
  ecr_repository_url  = module.secondary_ecr.repository_url
  container_image     = "${module.secondary_ecr.repository_url}:latest"
}

module "secondary_codecommit" {
  source = "./modules/codecommit"
  providers = {
    aws = aws.secondary
  }

  project_name = var.project_name
  environment  = var.environment
}

# CodeCommit Replication from Primary to Secondary
module "codecommit_replication" {
  source = "./modules/codecommit-replication"
  providers = {
    aws = aws.primary  # Lambda runs in primary region
  }

  project_name                 = var.project_name
  environment                  = var.environment
  source_region                = var.primary_region
  destination_region           = var.secondary_region
  source_repository_name       = module.primary_codecommit.repository_name
  destination_repository_name  = module.secondary_codecommit.repository_name
  source_repository_arn        = module.primary_codecommit.arn
  destination_repository_arn   = module.secondary_codecommit.arn
}

module "secondary_codepipeline" {
  source = "./modules/codepipeline"
  providers = {
    aws = aws.secondary
  }

  project_name        = var.project_name
  environment         = var.environment
  region              = var.secondary_region
  repository_name     = module.secondary_codecommit.repository_name
  ecr_repository_name = module.secondary_ecr.repository_name
  ecr_repository_url  = module.secondary_ecr.repository_url
  ecs_cluster_name    = module.secondary_ecs.cluster_name
  ecs_service_name    = module.secondary_ecs.service_name
  notification_email  = var.notification_email
}

module "secondary_monitoring" {
  source = "./modules/monitoring"
  providers = {
    aws = aws.secondary
  }

  project_name        = var.project_name
  environment         = var.environment
  region              = var.secondary_region
  ecs_cluster_name    = module.secondary_ecs.cluster_name
  ecs_service_name    = module.secondary_ecs.service_name
  alb_arn_suffix      = module.secondary_ecs.alb_arn_suffix
  target_group_arn_suffix = module.secondary_ecs.target_group_arn_suffix
  log_group_name      = module.secondary_ecs.log_group_name
  notification_email  = var.notification_email
}
