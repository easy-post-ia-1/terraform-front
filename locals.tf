locals {
  bucket_name = "easy-post-ia-frontend-prod-bucket"
  table_name  = "easy-post-ia-frontend-prod-table"

  ecr_repo_name = "easy-post-ia-frontend-prod"

  app_cluster_name             = "ProdFrontEndCluster"
  availability_zones           = ["us-east-2a", "us-east-2b", "us-east-2c"]
  app_task_family              = "easy-post-ia-frontend-prod"
  container_port               = 80
  app_task_name                = "deploy-frontend-prod"
  ecs_task_execution_role_name = "deploy-frontend-prod-task-execution-role"

  application_load_balancer_name = "easy-post-ia-frontend-prod-alb"
  target_group_name              = "easy-post-ia-frontend-prod-tg"

  app_service_name = "easy-post-ia-frontend-prod"
}

