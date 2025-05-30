terraform {
  required_version = "~> 1.3"

  backend "s3" {
    bucket         = "easy-post-ia-frontend-dev"
    key            = "tf-infra/dev.tfstate"
    region         = "us-east-2"
    dynamodb_table = "easy-post-ia-frontend-dev-table"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "tf-state" {
  source = "./modules/tf-state"

  bucket_name = local.bucket_name
  table_name  = local.table_name
  env         = local.env
}

module "ecrRepo" {
  source = "./modules/ecr"

  ecr_repo_name = local.ecr_repo_name
  env           = local.env
}

module "ecsCluster" {
  source = "./modules/ecs"

  app_cluster_name   = local.app_cluster_name
  availability_zones = local.availability_zones

  app_task_family              = local.app_task_family
  ecr_repo_url                 = module.ecrRepo.repository_url
  container_port               = local.container_port
  app_task_name                = local.app_task_name
  ecs_task_execution_role_name = local.ecs_task_execution_role_name

  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name
  app_service_name               = local.app_service_name
  env                            = local.env
  app_container_name             = local.app_container_name
}

