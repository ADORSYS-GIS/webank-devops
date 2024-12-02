# ArgoCD Setup and Authentication Documentation

1. ## Overview of the Project

This project uses ArgoCD for managing Kubernetes applications with a secure authentication mechanism via Keycloak. The setup is fully automated using Terraform to deploy ArgoCD and configure the authentication via OIDC (OpenID Connect) with Keycloak as the identity provider.

2. ## Prerequisites

    Before deploying ArgoCD, ensure the following:

    1. An AWS account, which you will need to deploy you cluster on AWS and with which resources like ACM certificates may be generated.


    2. Please read and understand  project before proceeding <ins> ***[README](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/README.md)***</ins>, you can also read this too, try to understand it.. it will open your mind as we proceed <ins> ***[PROJECT ENV](https://github.com/ADORSYS-GIS/webank-devops/blob/main/Docs/deploy_workflow.md)***</ins>
    
3. ## Terraform Configuration for ArgoCD Deployment
Our ArgoCD is deployed using Terraform. The deployment configuration is already included in the  <ins> ***[eks](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/eks.tf)***</ins> file, which ensures that ArgoCD is automatically installed and configured in the Kubernetes cluster.

```hcl
 enable_argocd = true
  argocd = {
    name          = "argocd"
    chart_version = "6.7.3"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argocd"
    values = [
      templatefile("${path.module}/files/argocd-values.yaml", {
        domain                = local.argocdDomain,
        name                  = local.name,
        certArn               = var.cert_arn,
        oidc_kc_client_id     = var.oidc_kc_client_id,
        oidc_kc_client_secret = var.oidc_kc_client_secret,
        oidc_kc_issuer_url    = var.oidc_kc_issuer_url,
      })
    ]
  }
```
 This configuration:
    1. enable_argocd = true: This part of the configuration controls whether ArgoCD will be deployed or not, for our case, yes
    2. Enables ArgoCD installation with Helm.
    3. Specifies the version of the ArgoCD chart (6.7.3).
    4. Configures the repository URL for the ArgoCD chart.
    5. Defines the namespace (argocd).
    6. Uses the <ins> ***[argocd-values.yaml](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/files/argocd-values.yaml)***</ins> file to provide necessary configuration, including the OIDC client settings, ACM certificate ARN, and domain name.

Once the <ins> ***[eks](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/eks.tf)***</ins> file is configured correctly, run Terraform to apply the changes:

```shell
terraform init
terraform plan
terraform apply
```
Terraform will automatically deploy ArgoCD to your Kubernetes cluster without the need for manual Helm installation.

4. ## Configuring ArgoCD for Authentication
**OIDC Configuration:**

Our ArgoCD uses Keycloak for user authentication, and this is configured in the <ins> ***[argocd-values.yaml](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/files/argocd-values.yaml)***</ins> file.

The following OIDC configuration is injected into the ArgoCD deployment through the <ins> ***[argocd-values.yaml](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/files/argocd-values.yaml)***</ins> :

```yaml
oidc.config: |
      name: Adorsys
      issuer: ${oidc_kc_issuer_url}
      clientID: ${oidc_kc_client_id}
      clientSecret: $oidc.keycloak.clientSecret
      requestedScopes: ["openid", "profile", "email", "groups"]
```
This tells ArgoCD to authenticate users via Keycloak, using the provided issuer URL, client ID, and client secret for the OIDC flow.

5. ##  Accessing ArgoCD

After ArgoCD is deployed by Terraform, access the ArgoCD web UI through the domain specified in the configuration (e.g. https://webank-ariel-test-me-argocd.dev.webank.gis.ssegning.com/ for our case).

This URL is provided by our   Terraform configuration and will automatically point to the ArgoCD service running in our Kubernetes cluster.

To get these URL after deploying the cluster, make sure you are inside our cluster context locally via the terminal, 

   1. execute ```kubectl get namespaces``` : This will display all namespace and you will see the argocd namespace, just get into the argocd namespace(**services**) and from there, you can access the url base on the configurations in the naming done in our terraform configurations files..

   To better understanding how the namings come about see the files <ins> ***[main](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/main.tf)***</ins> and <ins> ***[variables](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/variables.tf)***</ins>

   for the <ins> ***[main.tf](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/main.tf)***</ins>  file, look at :

   ```hcl
locals {
  name     = "webank-${var.name}"
  azs_count = length(var.azs)
  azs = var.azs
  argocdDomain = "${local.name}-argocd.${var.zone_name}"
  tags = {
    Owner       = local.name,
    Environment = var.environment
  }
}
   ```


6. ## Login to ArgoCD

Once the ArgoCD UI is accessed:

 **Login Flow:**

ArgoCD will redirect users to Keycloak for authentication via OIDC.
        After a successful login, you will be redirected back to the ArgoCD UI.
        Your access permissions will be governed by the **RBAC policies defined in the rbac.policy.csv file** (see next section).


7. ## RBAC Configuration (Role-Based Access Control)

ArgoCD uses **RBAC (Role-Based Access Control)** to manage user permissions. The rbac.policy.csv file defines the roles and the corresponding actions allowed for users.

see : <ins> ***[argocd-values.yaml](https://github.com/ADORSYS-GIS/webank-devops/blob/main/terraform/files/argocd-values.yaml)***</ins> 

Example rbac.policy.csv configuration in our project

```hcl
 rbac:
    policy.csv: |
      g, ArgoCDAdmins, role:admin
      g, ArgoCDViewer, role:readonly
```


**ArgoCDAdmins:** Users in this group have full admin access to ArgoCD.
**ArgoCDViewer:** Users in this group have read-only access to ArgoCD.

The RBAC policies ensure that users can only perform actions within their assigned roles.

9. ## Additional Resources for Developers

Here are some helpful resources to understand ArgoCD and Keycloak authentication:


https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/argocd-rbac-cm.yaml

https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md

https://github.com/aws-ia/terraform-aws-eks-blueprints-addons

https://github.com/argoproj/argo-helm