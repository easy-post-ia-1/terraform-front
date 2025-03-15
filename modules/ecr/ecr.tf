# Check if the ECR repository already exists
#data "external" "check_repo" {
#  program = ["/bin/bash", "${path.module}/verify_ecr.sh", var.ecr_repo_name, "us-east-2"]
#}

resource "aws_ecr_repository" "app_ecr_repo" {
  #count = data.external.check_repo.result.success == "true" ? 0 : 1
  name = var.ecr_repo_name
}
