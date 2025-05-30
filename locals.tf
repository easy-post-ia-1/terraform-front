locals {
  env = terraform.workspace

  bucket_name        = "easy-post-ia-frontend-${local.env}-bucket"
  table_name         = "easy-post-ia-frontend-${local.env}-table"
  ecr_repo_name      = "easy-post-ia-frontend-${local.env}"
  app_container_name = "easy-post-ia-frontend-${local.env}"

  app_cluster_name             = local.env == "prod" ? "ProdFrontEndCluster" : "DevFrontEndCluster"
  availability_zones           = ["us-east-2a", "us-east-2b", "us-east-2c"]
  app_task_family              = "easy-post-ia-frontend-${local.env}"
  container_port               = 3000
  app_task_name                = "deploy-frontend-${local.env}"
  ecs_task_execution_role_name = "deploy-frontend-${local.env}-task-execution-role"

  application_load_balancer_name = "easy-post-ia-frontend-${local.env}-alb"
  target_group_name              = "easy-post-ia-frontend-${local.env}-tg"
  app_service_name               = "easy-post-ia-frontend-${local.env}"
}

