# Developer's Guide: Onboarding a New Service to the Webank Platform

## 1. Introduction

This document provides a definitive, file-by-file walkthrough for integrating a new Helm chart into the `webank-devops` GitOps platform. The goal is to create a professional, reusable guide for developers.

We will use **Apache Fineract** as our real-world example. We will transform its standalone Helm chart into a fully integrated microservice within the `webank` application suite, managed by our production-grade infrastructure and deployment pipeline.

**The Philosophy:** Our platform separates concerns. `/terraform` builds the house (infrastructure on AWS). `/charts` contains the blueprints for the furniture (our applications). `/deploy` tells the movers (Argo CD) exactly where to put the furniture.

---

## 2. Phase 1: Preparing the Service Chart (`/charts/fineract`)

**Goal:** To transform the generic `fineract` chart into a standardized, configurable component that can be managed by our platform.

### 2.1. `Chart.yaml`: Standardizing Dependencies

**The Change:** We modified this file to use the project's standard `common` library chart and removed the direct `postgresql` dependency.

**Before:**
```yaml
dependencies:
  - name: postgresql
    version: "16.7.24"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
```

**After:**
```yaml
dependencies:
  - name: common
    version: 2.27.0
    repository: "https://repo.broadcom.com/bitnami-files/"
```

**Why:** The `common` chart is a shared library used by all other `webank` services. It contains standardized helpers for creating names and labels. By using it, we ensure Fineract's resources will look and feel exactly like every other service, which is critical for consistency. We removed the `postgresql` dependency because our platform uses a central, externally managed AWS RDS database, not an in-cluster one.

### 2.2. `values.yaml`: Creating a Chart API

**The Change:** We introduced a new `externalDatabase` section and set `postgresql.enabled: false`.

**Code Added:**
```yaml
# This new section will hold connection details for the external RDS
externalDatabase:
  host: ""
  port: 5432
  name: "fineract_tenants"
  user: "postgres"
  secretName: "rds-secret"
  secretKey: "password"

# Disable the embedded postgresql chart
postgresql:
  enabled: false # <--- THIS IS THE KEY CHANGE
```

**Why:** This creates a clean "API" for our chart. It decouples the chart from a hardcoded database configuration. Now, our production deployment system (Argo CD) can inject the real database connection details at runtime without having to modify the chart's internals.

### 2.3. `templates/deployment.yaml`: Consuming the New API

**The Change:** We updated the `env` section to use the variables from our new `externalDatabase` API.

**Before:**
```yaml
- name: FINERACT_HIKARI_JDBC_URL
  value: "jdbc:postgresql://{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.auth.database }}"
- name: FINERACT_HIKARI_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "fineract-helm-chart.fullname" . }}-db-secret
      key: username
# ... and so on for other DB variables
```

**After:**
```yaml
- name: FINERACT_HIKARI_JDBC_URL
  value: "jdbc:postgresql://{{ .Values.externalDatabase.host }}:{{ .Values.externalDatabase.port }}/{{ .Values.externalDatabase.name }}"
- name: FINERACT_HIKARI_USERNAME
  value: "{{ .Values.externalDatabase.user }}"
- name: FINERACT_HIKARI_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.secretName }}
      key: {{ .Values.externalDatabase.secretKey }}
# ... and so on for other DB variables
```

**Why:** This makes the Fineract application listen to the configuration we provide externally. It now expects to be told how to connect to a database, which is exactly what we want for a production environment.

### 2.4. `templates/fineract-db-secret.yaml`: Making Secrets Flexible

**The Change:** We wrapped the secret creation in a condition: `{{- if not .Values.externalDatabase.secretName }}`.

**Why:** This is a powerful pattern used by the other `webank` charts. It makes the chart flexible for different environments:
*   **For Local Testing:** If you don't specify a `secretName`, the chart will create its own database secret from the `user` and `password` in `values.yaml`.
*   **For Production:** Our Argo CD configuration *will* provide a `secretName` (`rds-secret`). This condition then becomes false, and the chart will not attempt to create its own secret, correctly using the one managed by Terraform.

### 2.5. `templates/setup-db-job.yaml`: The Automated Database Admin

**The Problem:** Fineract needs two databases (`fineract_tenants` and `fineract_default`). Our AWS RDS is provisioned with only one. 

**The Solution (What we did):** We created this new file to define a Kubernetes `Job`. A Job is a one-off task.

**Code:**
```yaml
{{- if .Values.externalDatabase.host }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "common.names.fullname" . }}-db-setup
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
# ... rest of the Job definition ...
```

**Why:** The `helm.sh/hook` annotation is the magic here. It tells Helm: "Before you even start installing or upgrading the main Fineract application, run this Job first and wait for it to succeed." The Job itself simply runs a PostgreSQL client that connects to our external RDS instance and creates the missing `fineract_default` database. This fully automates the database prerequisite, removing the need for any manual database administration.

---

## 3. Phase 2: Integrating into the `webank` Umbrella Chart

**Goal:** To make Fineract an official, routable service within the main `webank` application.

### 3.1. `charts/webank/Chart.yaml`: Adding to the Family

**The Change:** We added `fineract` to the `dependencies` list.

**Why:** This tells the main `webank` chart that Fineract is now one of its children. Deploying `webank` now means deploying `fineract` as well.

### 3.2. `charts/webank/templates/ingress.yaml`: Opening the Front Door

**The Change:** We added a new path-based rule to the `http.paths` list.

**Code Added:**
```yaml
- path: /fineract-provider
  pathType: Prefix
  backend:
    service:
      name: {{ $.Release.Name }}-fineract
      port:
        number: {{ ... }}
```

**Why:** The main Ingress acts as the central router for all incoming web traffic. This new rule tells the AWS Load Balancer: "Any traffic for `https://<your-domain>/fineract-provider` should be sent directly to the Fineract service inside our cluster." This makes the service accessible to the outside world.

---

## 4. Phase 3: Activating the Deployment with Argo CD

**Goal:** To provide the final, environment-specific configuration and let GitOps do the work.

### 4.1. `deploy/dev/webank.yaml`: The Master Control Panel

**The Change:** We added a new `fineract:` block inside the `helm.valuesObject` section.

**Code Added:**
```yaml
fineract:
  image:
    repository: apache/fineract
    tag: "latest"
  externalDatabase:
    host: webank-dev-env-db.cp4v71vs2xe2.eu-central-1.rds.amazonaws.com
    name: "fineract_tenants"
    user: "webank"
    secretName: "rds-secret"
    secretKey: "password"
```

**Why:** This is the final, crucial connection. This file defines the *exact* state of our `dev` environment. The block we added tells Argo CD to override the `fineract` chart's default values with the real production data. It injects the real AWS RDS database hostname and tells the chart to get its password from the `rds-secret` (which was created by Terraform). This is how we securely connect our application to our infrastructure without ever putting passwords in our code.

---

## 5. Conclusion

By executing these steps, we have successfully onboarded a brand new service onto a sophisticated DevOps platform. We followed established patterns for consistency, decoupled the application from its infrastructure, automated a critical database prerequisite, and used the GitOps controller to manage the final deployment. This process is robust, secure, and repeatable for any future services.