output "repository_url" {
  #value       = length(aws_ecr_repository.app_ecr_repo) > 0 ? aws_ecr_repository.app_ecr_repo[0].repository_url : ""
  value       = aws_ecr_repository.app_ecr_repo.repository_url
  description = "Debugging output for ECR repository"
}

