# EKS Terraform Setup

This Terraform configuration creates a basic AWS EKS cluster with the following resources:
- VPC with 3 availability zones and 3 private subnets
- EKS cluster with a node group (t3.medium instances)
- Outputs the `kubeconfig` for interacting with the EKS cluster

## Steps to Run


0. Create args for your tf command:
   ```shell
   export TF_VAR_db_username="db_username"
   export TF_VAR_db_password="db_username_password123"
   export TF_VAR_name="selast-test-me"
   export TF_VAR_region="eu-central-1"
   export TF_VAR_azs='["eu-central-1a", "eu-central-1b"]'
   ```

1. Initialize Terraform:  
   ```shell
   terraform init
   ```

2. Plan the Terraform configuration:
   ```shell
   terraform plan
   ```

3. Apply the configuration:
   ```shell
   terraform apply
   ```

4. Use `kubectl` to interact with the cluster.