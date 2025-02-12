# Deploying a New Webank Module

### Introduction

This guide provides a step-by-step process for deploying a new Webank module (microservice), such as webank-bankaccount. By following this guide, developers can set up a new service and integrate it seamlessly into the existing Webank ecosystem.

### Prerequisites

**Ensure you have access to:**

- #### The webank-devops GitHub repository 
  The repository where the terraform scripts, helm charts and other deployment-related files are located.

- #### Rights to add secrets and variables to webank-devops
  This is only required in the case where the new module being deployed requires external variables. These must be injected, as secrets or variables, depending on how sensitive they are, during the creation of the infrastructure via the terraform apply workflow. 

- #### ArgoCD access
  ArgoCD is what injects our application into the infrastructure set up by terraform. Access to it is normally granted to every member of the organization owning webank-devops (ADORSYS-GIS). Access to our ArgoCD is instrumental in monitoring the environment wherein our application is running.

### Steps to Deploy a New Webank Module

1. **Create a New Directory for the Module(Microservice)**

Navigate to the **charts/** directory at the root of **webank-devops/** and replicate an existing module directory (e.g., webank-userapp , webank-obs or webank-prs).

```code
cd charts
cp -r webank-userapp <name-of-new-module>
```
2. **Update Chart.yaml**

Of the newly created module's helm chart.

Modify the metadata inside charts/<name-of-new-module>/Chart.yaml:

```yaml
apiVersion: v2
name: <name-of-new-module>
description: A Helm chart for Kubernetes

type: application

version: 1.2.0

appVersion: "1.0.0"

dependencies:
  - name: common
    version: 2.27.0
    repository: https://repo.broadcom.com/bitnami-files/
```

**NOTE**: Everything in the **Chart.yaml** remains the same except the **version** and maybe the **dependencies..** because some modules might  not  need dependencies.. you can see for **webank-prs**. If the new module does not require dependencies, the whole dependency block should be removed.

3. **Update values.yaml**

Of the newly created module's helm chart.

Modify charts/<name-of-new-module>/values.yaml to set the correct Docker image tag:

```yaml
image:

  registry: ghcr.io
 
  repository: adorsys-gis/<name-of-new-module>

  tag: <insert tag to the newly deployed image of your module>

  digest: ""

  pullPolicy: Always
```
**NOTE:** 

In the **values.yaml** file you might also want to define the environtment variables for your new module, especially if you are first going to test a local deployment using minikube. 

Even if you *are* going for full-blown deployment, environment variables that your application needs that are not sensitive may also be added here. An example is in **webank-obs/values.yaml** with the variable SPRING_PROFILES_ACTIVE.

4. **Modify webank.yaml**

Update the **webank.yaml** file in deploy/dev/ to include the new module:

**NOTE:** Based on how our new module interacts with the frontend (webank-userapp), we need to define environment variables in the frontend that will be accessed by the webank-userapp. These endpoints must be updated in webank.yaml, as it serves as the central configuration point for our deployment. For example, we might define them as follows:

let's say this new module is webank-bankaccount

```yaml
userapp:
  image:
    tag: 48db13942061b31224dd7d4ca8c86ac9c49c4d41
    pullPolicy: Always
  env:
    - name: VITE_WEBANK_OBS_URL
      value: '/api'
    - name: VITE_WEBANK_PRS_URL
      value: '/api/prs'
    - name: VITE_WEBANK_BANKACCOUNT_URL
      value: '/api/bankaccount'

bankaccount:
  image:
    tag: <new-image-sha>
    pullPolicy: Always
  env: []
  envFrom:
    - secretRef:
        name: webank-bankaccount-secret
```
**NOTE:** The env configurations might differ base on if our module need envs related to database..

checkout how configurations were set for **webank-obs and webank-prs** in the **webank.yaml** to understand more

5. **Modify charts/webank/**

- Navigate to templates/ingress.yaml.. in this file is were you  we will define our application path prefixes base on how we configured them in our bankend **(rest-api)**...

```yaml
- host: {{ include "common.tplvalues.render" (dict "value" .host "context" $) }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $.Release.Name }}-userapp
                port:
                  number: {{ include "common.tplvalues.render" (dict "value" $.Values.userapp.service.port "context" $) }}
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: {{ $.Release.Name }}-obs
                port:
                  number: {{ include "common.tplvalues.render" (dict "value" $.Values.obs.service.port "context" $) }}
          - path: /api/prs
            pathType: Prefix
            backend:
              service:
                name: {{ $.Release.Name }}-prs
                port:
                  number: {{ include "common.tplvalues.render" (dict "value" $.Values.prs.service.port "context" $) }}
```

Notice how we defined paths for the webank-userapp, webank-obs and webank-prs... clean right?? Yesssss

To do same for a new modules, we copy, paste then modify the path field..nothing more and also the name field.. **(name: {{ $.Release.Name }}- <change to fit your module )**

Next-Step : Go to the values.yaml file and disable ingress..

```yaml
## Online Banking Service

obs:
  ingress:
    enabled: false

prs:
  ## Disable the prs ingress
  ingress:
    enabled: false

userapp:
  ## Disable the userapp ingress
  ingress:
    enabled: false

new-module:
    ingress:
      enabled: false
```

And finaly, visit the **Chart.yaml** and add the respective dependency to the new module

```yaml

apiVersion: v2
name: webank
description: A Helm chart for Kubernetes

type: application

version: 1.2.0-rc.2

appVersion: "1.16.0"

dependencies:
  - name: webank-obs
    repository: "https://ADORSYS-GIS.github.io/webank-devops/"
    version: 1.2.0
    alias: obs
  - name: webank-userapp
    repository: "https://ADORSYS-GIS.github.io/webank-devops/"
    version: 1.0.1
    alias: userapp
  - name: webank-prs
    repository: "https://ADORSYS-GIS.github.io/webank-devops/"
    version: 1.0.0
    alias: prs
  - name: new-module
    repository: "https://ADORSYS-GIS.github.io/webank-devops/"
    version: 1.x.x
    alias: nm
  - name: postgresql
    repository: "https://repo.broadcom.com/bitnami-files/"
    version: 16.2.3
    alias: db
    condition: db.enabled
  - name: common
    version: 2.27.0
    repository: "https://repo.broadcom.com/bitnami-files/"
```

###### Handling Secrets : 
In situations where new modules depend on environment variables or secrets, we'll use Terraform configurations to manage these dependencies. GitHub will store the secrets and environment variables securely.

It's important to update the workflow to include the necessary secrets, as currently, the following Terraform commands are being triggered by the workflow:

    terraform init
    terraform plan
    terraform apply (via workflow dispatch)

When handling secrets, the relevant files involved are:

    terraform/secret.tf
    terraform/variables.tf

By reviewing these files, along with the **webank-prs module**, you'll see how everything connects. Make sure to include the environment variables in the workflow when executing the above Terraform commands.




**Deploy the Helm Chart for testing..**

  you can use **minikube** during this process..
 Run the following commands to package and deploy the new Helm chart:

- helm dependency build/update
- helm upgrade --install webank . --namespace staging --create-namespace 

and after that, our new module should be live....