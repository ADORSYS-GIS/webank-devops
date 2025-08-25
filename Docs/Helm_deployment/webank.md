
# Webank Helm chart Documentation

## Introduction to Webank

The **Webank** project serves as the **entry point** for deploying two key components of an application:

1. **Backend Service (`webank-obs`)**: Handles business logic, APIs, and data management.
2. **Frontend Application (`webank-userapp`)**: Provides the user interface for interacting with the application.

### Purpose

Webank is designed to simplify deployment by unifying the deployment processes of these two components using a **Helm chart**. Instead of deploying the backend and frontend individually, Webank ensures that both are deployed together with appropriate configurations, ingress routing, and resource management.

---

## Features of Webank

1. **Unified Deployment**:
   - Combines the `webank-obs` and `webank-userapp` Helm charts as dependencies.
   - Manages ingress routing for seamless access to both services.

2. **Ingress Management**:
   - Configures a single entry point for the backend (`/api`) and frontend (`/`) using AWS ALB.

3. **Scalability**:
   - Allows customization of replica counts, service types, and ingress rules.

4. **Modular Design**:
   - Each component (backend and frontend) is treated as a subchart, making it easy to manage and extend.

---

## Prerequisites

To deploy Webank, ensure you meet the following requirements:

### Kubernetes Setup
- A running **Kubernetes cluster**.
- Kubernetes CLI tool (`kubectl`) installed and configured to interact with your cluster.

### Helm
- Helm v3 installed for managing the charts.

### AWS Setup (for Ingress)
- An AWS account with **ALB (Application Load Balancer)** configured.
- An SSL certificate managed by AWS ACM (Amazon Certificate Manager).
- Domain name configuration pointing to the ALB.

---

## Project Structure

The `webank` directory is organized as follows:

```plaintext
webank/
├── Chart.yaml          # Metadata and dependencies for the chart.
├── values.yaml         # Global configuration for the backend and frontend.
├── templates/          # Helm templates for defining Kubernetes resources.
│   ├── ingress.yaml    # Defines the ingress for routing traffic.
│   └── NOTES.txt       # Post-deployment instructions.
├── charts/             # Contains subcharts for the backend and frontend.
│   ├── webank-obs-0.1.0.tgz
│   └── webank-userapp-0.1.0.tgz
```

---

## Key Files

### 1. **`Chart.yaml`**
This file defines the metadata for the Webank chart and lists its dependencies:

```yaml
apiVersion: v2                  # Specifies the Helm chart API version.
name: webank                    # Name of the Helm chart.
description: A Helm chart for deploying the Webank application. 
type: application               # Type of chart (application or library).
version: 0.1.0                  # Version of the Helm chart.
appVersion: "1.16.0"            # Version of the application being deployed.

dependencies:                   # Defines dependencies (subcharts).
  - name: webank-obs            
    repository: "file://../webank-obs" # Path to the subchart directory.
    version: 0.1.0              
    alias: obs                 

  - name: webank-userapp       
    repository: "file://../webank-userapp" #
    version: 0.1.0              
    alias: userapp             

```

---

### 2. **`values.yaml`**
This file provides global configuration for both the backend and frontend:

```yaml
obs:                            # Configuration specific to the backend (webank-obs).
  service:                      # Service-related configurations.
    type: ClusterIP             # Exposes the service only within the cluster.
  ingress:
    enabled: false              # Ingress is managed by the parent chart, not the subchart.

userapp:                        
  service:
    type: ClusterIP             
  ingress:
    enabled: false             

```

---

### 3. **`templates/ingress.yaml`**

This file defines the ingress configuration for routing HTTP/HTTPS traffic to the backend and frontend:

```yaml
apiVersion: networking.k8s.io/v1  # API version for ingress resource.
kind: Ingress                     # Specifies that this is an ingress resource.
metadata:
  name: webank-ingress            # Name of the ingress resource.
  annotations:                    # Annotations for configuring the AWS ALB.
    alb.ingress.kubernetes.io/scheme: internet-facing  # ALB is public-facing.
    alb.ingress.kubernetes.io/listen-ports: |          # Ports for HTTP and HTTPS.
      [ { "HTTP": 80 }, { "HTTPS": 443 } ]
    alb.ingress.kubernetes.io/load-balancer-name: webank-lb # Name of the ALB.
    alb.ingress.kubernetes.io/certificate-arn: <SSL_CERT_ARN> # SSL certificate ARN.
    alb.ingress.kubernetes.io/ssl-redirect: '443'     # Redirects HTTP to HTTPS.
    alb.ingress.kubernetes.io/target-type: 'ip'       # Targets IP-based services.

spec:
  ingressClassName: alb           # Specifies the ingress class (AWS ALB in this case).
  rules:                          # Routing rules for the ingress.
    - host: dev.webank.gis.ssegning.com  # Hostname for the ingress.
      http:
        paths:
          - path: /               # Routes traffic to the frontend at the root path.
            pathType: Prefix      # Matches paths with this prefix.
            backend:              # Specifies the service and port for the frontend.
              service:
                name: webank-userapp
                port:
                  number: 80
          - path: /api            # Routes traffic to the backend at the `/api` path.
            pathType: Prefix      # Matches paths with this prefix.
            backend:              # Specifies the service and port for the backend.
              service:
                name: webank-obs
                port:
                  number: 8080

```

---

## How Webank Works

1. **Combining Subcharts**:
   - The `webank` chart aggregates the backend and frontend subcharts.
   - Global configurations in `values.yaml` can override settings in the subcharts.

2. **Ingress Management**:
   - The ingress routes external traffic to the appropriate service based on the path:
     - `/` → `webank-userapp`
     - `/api` → `webank-obs`

3. **Deployment Process**:
   - The `helm install` command deploys all components simultaneously:
     - Backend (`webank-obs`): Runs on port `8080`.
     - Frontend (`webank-userapp`): Runs on port `80`.

4. **Scalability**:
   - You can increase replica counts or adjust resource limits in `values.yaml`.

---

## Step-by-Step Deployment Guide

### Deployment Steps

1. **Package the Subcharts**:
   - Navigate to the `webank` directory:
     ```bash
     helm dependency build  
     ```
   - The `.tgz` files of the `webank-obs` and `webank-userapp` will be creates inside the `webank/charts/` directory.

2. **Deploy the Chart**:
   - Navigate to the `webank` directory and install the chart:
     ```bash
   helm upgrade --install webank . -n testing --create-namespace    
     
     ```

3. **Verify the Deployment**:
   - Check the status of the Helm release:
     ```bash
     helm status webank
     ```
   - Inspect the Kubernetes resources:
     ```bash
     kubectl get all
     kubectl describe ingress webank-ingress
     ```
4. **Test the Application**

    Access your  service to ensure it works. You can:
    1. Port-forward the  service:
      ```bash
      kubectl port-forward svc/webank 8080:8080 -n testing
      ```
    2. Use tools like `curl` or `Postman` to interact with the backend 

5. **Access the Application**:
   - Open the frontend in your browser: `http://dev.webank.gis.ssegning.com`
   - API calls to the backend will be routed through `/api`.

---

## Key Points to Emphasize

- **Centralized Management**: Webank simplifies the deployment process by combining backend and frontend deployments.
- **Ingress Flexibility**: Configurations are tailored for AWS ALB but can be adapted for other ingress controllers.
- **Customizability**: `values.yaml` allows fine-tuning of configurations without modifying the charts directly.

## For More Resources

To learn more about configuring and working with Helm, explore the following resources:

- [Helm Official Documentation](https://helm.sh/docs/)
- [Getting Started with Helm Charts](https://helm.sh/docs/chart_template_guide/getting_started/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Deploying Applications with Helm](https://kubernetes.io/docs/tutorials/helm/deploy-applications/)
- [AWS ALB Ingress Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [setting up helm chart](https://phoenixnap.com/kb/create-helm-chart)
  