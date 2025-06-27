# 🚀 terraform-front

This project contains the Terraform configuration for the **frontend infrastructure** of the Sena project.

## 📁 Structure
- `main.tf`: Main Terraform configuration.
- `locals.tf`: Local variables and naming conventions.
- `providers.tf`: Provider configuration.
- `modules/`: Contains reusable Terraform modules (ECR, ECS, tf-state).

## 🛠️ Usage
1. Initialize Terraform:
   ```sh
   terraform init
   ```
2. Review the plan:
   ```sh
   terraform plan
   ```
3. Apply the configuration:
   ```sh
   terraform apply
   ```

## 📋 Requirements
- Terraform >= 1.3
- AWS credentials with appropriate permissions

## 🔗 Related Projects
- [terraform-back](../terraform-back): Backend infrastructure configuration

## 📝 License
MIT (applies to both frontend and backend projects) 