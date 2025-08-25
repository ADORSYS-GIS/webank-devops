### Documentation for **Webank UserApp**

Below is the comprehensive documentation for **Webank UserApp**, the Helm chart responsible for deploying the frontend services of the Webank application.

---

## **Overview**
**Webank UserApp** is designed to deploy the frontend of the Webank application. It includes all necessary configurations, such as deployments, services, and other Kubernetes resources, to ensure the smooth operation of the frontend services. This Helm chart is modular and can be managed independently.

---

## **Project Structure**
The Webank UserApp directory contains the following files and directories:

```plaintext
webank-userapp
├── Chart.yaml           # Contains metadata about the chart
├── templates/           # Directory for Kubernetes resource templates
│   ├── deployment.yaml  # Template for the frontend Deployment resource
│   ├── service.yaml     # Template for the Service resource
│   ├── serviceaccount.yaml # Template for ServiceAccount resource
│   ├── NOTES.txt        # Chart usage notes
│   └── tests/           # Tests for verifying the deployment
│       └── test-connection.yaml # Basic connectivity test template
└── values.yaml          # Default configurations for the chart
```

---

## **Main Files Explained**

### 1. **Chart.yaml**
Defines metadata for the Helm chart:
```yaml
apiVersion: v2
name: webank-userapp
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```
- **name**: The name of the chart.
- **description**: A brief description of the chart.
- **version**: The version of the chart.
- **appVersion**: The version of the application being deployed.

### 2. **values.yaml**
Contains default values used by the chart:
```yaml
app:
  name: webank-userapp

replicaCount: 2

image:
  repository: ghcr.io/adorsys-gis/webank-userapp
  tag: latest

service:
  type: ClusterIP
  port: 80
```
- **app.name**: The name of the application.
- **replicaCount**: Number of replicas for the deployment.
- **image.repository**: The Docker image repository for the frontend.
- **service.type**: Type of service (ClusterIP).
- **service.port**: The port exposed by the service.

### 3. **deployment.yaml**
Template for creating a Deployment resource:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.app.name }}
    spec:
      containers:
        - name: {{ .Values.app.name }}
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          ports:
            - containerPort: 80
```
**Key Points**:
- Uses values from `values.yaml` for flexibility.
- Deploys the specified Docker image.
- Defines the container port as `80` (standard HTTP port for frontend).

### 4. **service.yaml**
Template for creating a Service resource:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.app.name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Values.app.name }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: 80
```
**Key Points**:
- Exposes the frontend as a Kubernetes Service.
- Maps the Service port to the container port.

---

## **How It Works**
1. **Deployment**:
   - The `deployment.yaml` file provisions a specified number of replicas of the frontend application.
   - It pulls the container image from the specified Docker registry.

2. **Service**:
   - The `service.yaml` file creates a Kubernetes Service to expose the frontend.
   - It ensures communication within the cluster via the `ClusterIP`.

3. **Configuration**:
   - `values.yaml` is used to pass customizable values to the templates. This allows flexibility without modifying the template files.

4. **Scaling**:
   - The `replicaCount` value in `values.yaml` controls the number of frontend instances.

---

## **Prerequisites**
Before deploying the Webank UserApp chart, ensure the following:
- Kubernetes cluster is up and running.
- Helm CLI is installed and configured.
- Docker image for the frontend is available and accessible.
- Necessary RBAC permissions are set up in the cluster.

---

## **Steps to Deploy Webank UserApp**
1. Clone the repository:
   ```bash
   git clone https://github.com/ADORSYS-GIS/webank-devops

   cd webank-userapp
   ```
2. Deploy the chart:
   ```bash
   helm upgrade --install webankuserapp . -n testing --create-namespace    
   ```
4. Verify the deployment:
   ```bash
   kubectl get pods
   kubectl get services
   ```

---

## **For More Resources**
To learn more about Helm and Kubernetes, explore:
- [Helm Official Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Understanding Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [setting up helm chart](https://phoenixnap.com/kb/create-helm-chart)
