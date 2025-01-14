
# Steps followed to provision our k8s cluster with a PostgreSQL database using Helm

This guide explains how to provision a Kubernetes cluster with a PostgreSQL database using the Bitnami PostgreSQL Helm chart and configure a Spring Boot backend Helm chart to connect to the database. We'll outline the steps for deploying the database and backend, passing configuration values securely using `values.yaml` and Kubernetes secrets.

---

## Prerequisites
1. **Helm** installed on your local machine.
2. A running **Kubernetes cluster** (e.g., Minikube, EKS, or GKE).
3. **kubectl** configured to connect to the cluster.
4. **A Spring Boot backend Helm chart** already created.

---

## Step 1: Deploy PostgreSQL with Bitnami Helm Chart

The Bitnami PostgreSQL Helm chart simplifies the process of deploying and managing PostgreSQL in Kubernetes.

### Add the Bitnami Helm Repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Create a `values-postgres.yaml` file
Define the PostgreSQL configuration, including database credentials, in a custom `values-postgres.yaml` file. Here's an example:

```yaml
primary:
  service:
      type: ClusterIP
      port: 5432
auth:
  username: webank-user
  password: webank-password
  database: webank-db

metrics:
  enabled: true
```

### Deploy PostgreSQL
Deploy the Bitnami PostgreSQL chart using the custom configuration file:

```bash
helm install webank-db bitnami/postgresql -f values-postgres.yaml --namespace testing --create-namespace
```

### Verify PostgreSQL Deployment
Check the Persistent Volume Claims (PVCs) and Pods to confirm the PostgreSQL deployment:

```bash
kubectl get pvc -n testing
kubectl get pods -n testing
```

---

## Step 2: Configure the Spring Boot Backend Helm Chart

To connect your backend to PostgreSQL, you need to pass the database configuration as environment variables to the Spring Boot container.

### Update the `values.yaml` File in the Backend Helm Chart
Modify the `values.yaml` file in your Spring Boot Helm chart to define the necessary database variables:
    port: 5432


```yaml
app:
  name: webank-backend

replicaCount: 1

image:
  repository: myrepo/webank-backend
  tag: latest

database:
  host: webank-db
  port: 5432
  user: webank-user
  name: webank-db
  secretName: webank-db-secret

springBoot:
  profiles: "prod"
```

### Create a Kubernetes Secret for the Database Password
Generate a Kubernetes secret for the database password:

```bash
kubectl create secret generic webank-db-secret --namespace testing --from-literal=password=webank-password
```

### Update the `deployment.yaml` File in the Backend Helm Chart
Modify your `deployment.yaml` to pass the database credentials to the Spring Boot application via environment variables:

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
          env:
            - name: SPRING_DATASOURCE_URL
              value: "jdbc:postgresql://{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}"
            - name: SPRING_DATASOURCE_USERNAME
              value: "{{ .Values.database.user }}"
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.database.secretName }}
                  key: password
            - name: SPRING_PROFILES_ACTIVE
              value: "{{ .Values.springBoot.profiles }}"
          ports:
            - containerPort: 8080
```

### Deploy the Spring Boot Backend
Run the following command to deploy the Spring Boot backend Helm chart:

```bash
helm install webank-backend ./path-to-your-backend-helm-chart -f values.yaml --namespace testing
```

---

## Step 3: Verify Deployment and Connectivity

### Check Pods and Services
Ensure all Pods are running in the `testing` namespace:

```bash
kubectl get pods -n testing
kubectl get svc -n testing
```

### Test Database Connectivity
You can log into the PostgreSQL database pod to test the connection:

```bash
kubectl exec -it <postgresql-pod-name> -n testing -- psql -U webank-user -d webank-db
```

Run SQL commands to confirm the database is set up correctly:

```sql
\l  -- List all databases
\dt -- List all tables
```

---

## Step 4: Test the Application

Access your backend service to ensure it connects to the database. You can:
1. Port-forward the backend service:
   ```bash
   kubectl port-forward svc/webank-backend 8080:8080 -n testing
   ```
2. Use tools like `curl` or `Postman` to interact with the backend API and verify database operations.

---

## Conclusion
By following these steps, you've successfully provisioned a PostgreSQL database and configured a Spring Boot backend in your Kubernetes cluster using Helm. This setup ensures secure management of sensitive configurations and a seamless integration between the database and backend application.
