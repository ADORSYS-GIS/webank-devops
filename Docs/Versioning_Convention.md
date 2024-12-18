# Versioning convention adopted for helm charts of webank project
Versioning is an important part, if not the crux itself, of managing releases of project artifacts-no, projects in general rather. It is the way by which all relevant changes, which come inherently with the improvement of a project, whether functionality-wise, styling-wise or structure-wise, are tracked and kept track of. 

This record-keeping is important in just about all aspects of managing a project&mdash;more so **when this is done by a team.** However, here we will talk only about how we will implement versioning to handle one kind of project-related entity, the **artifact**&mdash;more specifically, our **helm charts.** 

Let us now get to it, how we will version **webank helm charts.** 

## Composite chart for webank
Below is the typical layout for our composed webank chart annotated with some explanation

```yaml
apiVersion: v2
name: webank
description: A Helm chart for Kubernetes

type: application 

version: 1.0.0              <-------------------------(1) version for composite helm chart to be released to repo

appVersion: "1.16.0"        <-------------------------(2) version for composite application that the current helm chart version uses

dependencies:
  - name: webank-obs
    repository: "https://adorsys-gis.github.io/webank-devops/"
    version: 0.1.0          <-------------------------(3) version to be pulled from repo for dependency build before release 
    alias: obs
  - name: webank-userapp
    repository: "https://adorsys-gis.github.io/webank-devops/"
    version: 0.1.0          <-------------------------(4) version to be pulled form repo during dependency build
    alias: userapp
  - name: postgresql
    repository: "https://charts.bitnami.com/bitnami"
    version: 16.2.3         <-------------------------(5) same as above, but less relevant as it comes form an external project repo
    alias: db
    condition: db.enabled
  - name: common
    version: 2.27.0         <-------------------------(6) same as above
    repository:https://repo.broadcom.com/bitnami-files/
```

### Explanation
Using this composite helm chart is not mandatory: it is more just an aid to us, allowing us to provision all of our services into our k8s cluster by running only a single ```helm install``` command since IT has the ability to call everything else we need. It does so via the ```dependencies``` block as you can see above.

**(1):** This is the version of our composite helm chart(webank) which pulls both the frontend(user-app) and backend(obs) helm charts together with some other dependencies for their proper functioning. The version here should change whenever there is a record-worthy change to ANY one of the helm chart files of the **webank** chart

**(2):** This one is related to the version of the composite application that the helm chart uses. It changes depending on the version of the artifact(docker image in our case) of our application that this helm chart is seeking to provision to our cluster.
It does not vary with changes done to helm chart files

**NOTE:** This app Version may or may not correpond exactly to the version of the docker image we're pulling. This is just a version from helm's perspective, not the universally exact one. To simply things for the future, however, we may make this correspond exactly to the app vesion.

**(3) and (4):** Versions of obs and userapp to be pulled from our remote repo whenever we do an install using this composite chart.

**(5) and (6):** External helm charts used in our infrastructure. We won't be versioning these. The current versions have all the appropriate functionalities we need and won't be improved upon by us.

## Composing charts for webank (obs and userapp)
Now for the main sub-charts of webank.

### Chart for webank-obs 
```yaml
apiVersion: v2
name: webank-obs
description: A Helm chart for Kubernetes

type: application

version: 1.0.0            <---------------------------(7) version for obs helm chart to be released to repo

appVersion: "1.0.0"       <---------------------------(8) version for obs(docker image) that the current helm chart version uses

dependencies:             <------- Same as (5) and (6) above ---------->
  - name: common
    version: 2.27.0
    repository:https://repo.broadcom.com/bitnami-files/
```

### Chart for webank-userapp
```yaml
apiVersion: v2
name: webank-userapp
description: A Helm chart for Kubernetes

type: application

version: 1.0.0            <---------------------------(9) version for obs helm chart to be released to repo

appVersion: "1.0.0"       <---------------------------(10) version for obs helm chart to be released to repo

dependencies:             <------- Same as (5) and (6) above ---------->
  - name: common
    version: 2.27.0
    repository:https://repo.broadcom.com/bitnami-files/
```

### Explanation
**(7):** Version of helm chart for backend application. Similar to **(1)** above. This version changes with changes to helm files of the **webank-obs** helm chart.

**(8):** Version of backend application being provisioned by the current helm chart version(version above). Similar to **(2)** above. This version changes according to the version of the backend artifact used by helm. It also may or may not reflect the artifact version exactly.

**(9):** Version of helm chart for frontend application. Similar to **(7)** and **(1)** above. This version changes with changes to helm files of the **webank-userapp** helm chart.

**(10):** Version of frontend application being provisioned by the current helm chart version(version just above). Similar to **(8)** and **(2)** above. This version changes according to the version of the frontend artifact used by helm. It also may or may not reflect the artifact version exactly.

---
---
### That's it for how we'll keep track of webank helm chart artifacts. Happy versioning!