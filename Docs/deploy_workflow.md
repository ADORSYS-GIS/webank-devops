# Terraform Deployment Workflow Documentation

## Overview

This workflow is designed to automate the deployment of Terraform-based infrastructure. It ensures:
- **Security**: By validating the code with `tfsec` for vulnerabilities.
- **Best Practices**: By linting the code with `tflint`.
- **Controlled Deployment**: With manual triggers (`workflow_dispatch`) and automated checks.

The workflow is structured into two primary jobs: `checks` (for validation) and `deploy` (for deployment).

---

## Workflow Breakdown

### Workflow Name
```yaml
name: Terraform Deployment
```
- **Purpose**: This name appears in the GitHub Actions UI to easily identify the workflow.

---

## Triggers

### Configuration
```yaml
on:
  workflow_dispatch:
  push:
    branches:
      - '*'
```

1. **`workflow_dispatch`**:
   - **What**: Enables manual execution of the workflow.
   - **Why**: Gives operators control over when deployments occur.

2. **`push`**:
   - **What**: Automatically triggers the workflow for the deploy branch when code is pushed.
   - **Why**: Ensures every code change to the deploy branch is validated immediately.

---

## Defaults

### Configuration
```yaml
defaults:
  run:
    working-directory: ./terraform
```
- **What**: Specifies `./terraform` as the default directory for all commands.
- **Why**: Keeps Terraform-related files in a consistent location and eliminates the need to specify the directory repeatedly.

---

## Jobs

### 1. **Checks Job**

#### Purpose
The `checks` job validates the Terraform code using:
1. **`tfsec`**: To identify security vulnerabilities.
2. **`tflint`**: To enforce best practices and catch errors.

---

#### Configuration
```yaml
jobs:
  checks:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        checks: [tfsec, tflint]
```

- **Runs-on**: The job executes on an `ubuntu-latest` runner.
- **Matrix Strategy**: Executes `tfsec` and `tflint` in parallel, reducing runtime.
- To learn more about the matrix strategy you can follow the link   <ins> ***[here](https://www.geeksforgeeks.org/the-matrix-strategy-in-github-actions/)***</ins>

#### Matrix Commands
```yaml
matrix:
  checks: [tfsec, tflint]
  include:
    - checks: tfsec
      commands: |
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
        tfsec .
    - checks: tflint
      commands: |
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        tflint --init
        tflint
```

1. **`tfsec`**:
   - Downloads and installs `tfsec`.
   - Scans the Terraform files for security misconfigurations.
   - **Why**: Ensures the Terraform code adheres to security standards.

2. **`tflint`**:
   - Installs `tflint` and initializes its configuration.
   - Runs a linting process to check for syntax issues, deprecated syntax, and misconfigurations.
   - **Why**: Improves code quality and reliability.

#### Steps
```yaml
steps:
  - name
    uses: actions/checkout@v4
```
- **Purpose**: Checks out the repository code so the workflow can access Terraform files.
- **Why**: Required for any workflow that operates on the repository's code.

```yaml
  - name: Set up Terraform
    uses: hashicorp/setup-terraform@v2
    with:
      terraform_version: 1.9.8
```
- **Purpose**: Configures the GitHub Actions runner to use a specific version of Terraform (`1.9.8`).
- **Why**: Ensures the correct Terraform version is used, avoiding compatibility issues.

```yaml
  - name: Do checks
    run: ${{ matrix.commands }}
```
- **Purpose**: Executes the appropriate commands (`tfsec` or `tflint`) based on the matrix configuration.
- **Why**: Allows running multiple checks efficiently in parallel.

---

### 2. **Deploy Job**

#### Purpose
The `deploy` job applies the validated Terraform code to provision infrastructure.

---

#### Dependencies
```yaml
needs:
  - checks
```
- **Purpose**: Ensures the deployment only runs if the `checks` job passes.
- **Why**: Prevents deploying unvalidated or potentially insecure code.

---

#### Configuration
```yaml
runs-on: ubuntu-latest
name: Deploy to ${{ matrix.name }} Environment
environment:
  name: ${{ matrix.name }}
  url: https://${{ env.DOMAIN_NAME }}
strategy:
  matrix:
    env:
      - dev
    include:
      - env: dev
        name: development
        description: "Deploy to Dev Environment"
```

1. **Environment Matrix**:
   - Defines the `dev` environment for deployment.
   - Includes metadata such as `name` and `description` for clear identification.
   - **Why**: Supports scalability for future environments (e.g., staging, production).

2. **Dynamic Environment**:
   - `environment` specifies the deployment environment (`development`) and its associated URL.
   - **Why**: Allows GitHub Actions to manage environment variables and secrets securely.

---

#### Steps

##### 1. **Checkout Code**
```yaml
- name: Checkout Code
  uses: actions/checkout@v4
```
- Same as in the `checks` job.

##### 2. **Set up Terraform**
```yaml
- name: Set up Terraform
  uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.9.8
```
- Same as in the `checks` job.

##### 3. **Configure AWS Credentials**
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
```
- **Purpose**: Configures the AWS CLI with the necessary credentials and region.
- **Why**: Enables Terraform to authenticate with AWS for resource provisioning.

##### 4. **Set Environment Variables**
```yaml
- name: Set DB Password and Username as Environment Variables
  run: |
    echo "TF_VAR_name=${{ matrix.env }}-cluster" >> $GITHUB_ENV
    echo "TF_VAR_db_username=${{ env.DB_USERNAME }}" >> $GITHUB_ENV
    echo "TF_VAR_db_password=${{ secrets.DB_PASSWORD }}" >> $GITHUB_ENV
    echo "TF_VAR_oidc_kc_client_id=${{ env.OIDC_KC_CLIENT_ID }}" >> $GITHUB_ENV
    echo "TF_VAR_oidc_kc_client_secret=${{ secrets.OIDC_KC_CLIENT_SECRET }}" >> $GITHUB_ENV
    echo "TF_VAR_oidc_kc_issuer_url=${{ env.OIDC_KC_ISSUER_URL }}" >> $GITHUB_ENV
    echo "TF_VAR_cert_arn=${{ env.CERT_ARN }}" >> $GITHUB_ENV
    echo "TF_VAR_region=${{ env.AWS_REGION }}" >> $GITHUB_ENV
    echo "TF_VAR_azs=${{ env.AWS_AVAILABLE_ZONES }}" >> $GITHUB_ENV
    echo "TF_VAR_zone_name=${{ env.DOMAIN_NAME }}" >> $GITHUB_ENV
```
- **Purpose**: Exports environment variables required by Terraform as `TF_VAR_*`.
- **Why**: Enables parameterized configurations in Terraform scripts, improving flexibility and security.

##### 5. **Terraform Init**
```yaml
- name: Terraform Init
  run: terraform init -var-file=${{ matrix.env }}.tfvars
```
- **Purpose**: Initializes Terraform, downloading required plugins and setting up the backend.
- **Why**: Prepares Terraform for plan and apply stages.

##### 6. **Terraform Validate**
```yaml
- name: Terraform Validate
  run: terraform validate -var-file=${{ matrix.env }}.tfvars
```
- **Purpose**: Validates the Terraform configuration files.
- **Why**: Ensures syntax correctness and structural integrity before planning.

##### 7. **Terraform Plan**
```yaml
- name: Terraform Plan
  run: terraform plan -var-file=${{ matrix.env }}.tfvars -out=plan.tfplan
```
- **Purpose**: Creates an execution plan (`plan.tfplan`) based on the configuration.
- **Why**: Provides a safe preview of changes Terraform will apply.

##### 8. **Terraform Apply**
```yaml
- name: Terraform Apply
  if: github.event_name == 'workflow_dispatch'
  run: terraform apply -auto-approve plan.tfplan
```
- **Purpose**: Applies the execution plan to provision infrastructure.
- **Conditional**: Only runs for manually triggered events (`workflow_dispatch`).
- **Why**: Prevents unintended deployments from automated triggers.

---

## Key Advantages of This Workflow

1. **Parallel Execution**:
   - The matrix strategy in the `checks` job reduces runtime by running `tfsec` and `tflint` simultaneously.

2. **Manual Control**:
   - `workflow_dispatch` ensures deployments are only executed intentionally.

3. **Secure Credential Management**:
   - AWS credentials and sensitive values (e.g., DB passwords) are securely stored as GitHub Secrets.

4. **Environment Scalability**:
   - Matrix configurations allow for easy addition of new environments (e.g., staging, production).

5. **Validation and Best Practices**:
   - Validates and enforces best practices, minimizing the risk of deploying flawed infrastructure.

6. **Comprehensive Error Prevention**:
   - Checks and validation steps ensure that only safe and verified configurations reach the deployment stage.
```