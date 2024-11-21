# EKS Terraform Setup

This Terraform configuration creates a basic AWS EKS cluster with the following resources:
- VPC with 3 availability zones and 3 private subnets
- EKS cluster with a node group (t3.medium instances)
- Outputs the `kubeconfig` for interacting with the EKS cluster

## Steps to Run

1. Initialize Terraform:  
   `terraform init`

2. Plan the Terraform configuration:  
   `terraform plan`

3. Apply the configuration:  
   `terraform apply`

5. Use `kubectl` to interact with the cluster.
