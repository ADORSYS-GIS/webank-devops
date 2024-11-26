# EKS Terraform Setup

This Terraform configuration creates a basic AWS EKS cluster with the following resources:
- VPC with 3 availability zones and 3 private subnets
- EKS cluster with a node group (t3.medium instances)
- Outputs the `kubeconfig` for interacting with the EKS cluster

## Steps to Run


0. Create args for your tf command:
   ```shell
   export TF_VAR_cert_arn="arn:aws:acm:eu-central-1:571075516563:certificate/f839eb2b-d11f-4272-bcf2-1b37b1013dd7"
   export TF_VAR_oidc_kc_client_id="webank-argocd-dev"
   export TF_VAR_oidc_kc_client_secret="6nKSCC73JxOhkxlAy6eLQvQleWZeaTIW"
   export TF_VAR_oidc_kc_issuer_url="https://accounts.ssegning.com/auth/realms/konk"
   export TF_VAR_zone_name="gis.ssegning.com"
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