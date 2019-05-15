# Jenkins X Helm Charts

[Jenkins X](https://jenkins-x.github.io/jenkins-x-website/) is an integrated CI / CD platform for any Kubernetes cluster or cloud.  Simple installation of best of breed open source software for developing and running applications in the cloud.

What's included out of the box?

|                                   |                                       |
| --------------------------------- | ------------------------------------- |
|![Jenkins](https://raw.githubusercontent.com/jenkins-x/jenkins-x-platform/master/jenkins-x-platform/images/jenkins.png)   | __Jenkins__ - Fully integrated CI / CD solution with opinionated yet customisable pipelines and environments |
|![Sonatype Nexus 3](https://raw.githubusercontent.com/jenkins-x/jenkins-x-platform/master/jenkins-x-platform/images/nexus.png) | __Nexus__ - Artifact repository (pluggable so we can switch with Artifactory) |
|![Chartmuseum](https://raw.githubusercontent.com/jenkins-x/jenkins-x-platform/master/jenkins-x-platform/images/chartmuseum.png) | __Chartmuseum__ - Helm Chart repository (Helm is the most popular Kubernetes package manager used to install and upgrade your applications)|
|![Monocular](https://raw.githubusercontent.com/jenkins-x/jenkins-x-platform/master/jenkins-x-platform/images/bitnami.png) | __Monocular__ - Web UI for searching and discovering Helm Charts |

Easy to install addons to come.

# Install

We use a CLI tool called [jx](https://github.com/jenkins-x/jx) to interact with Jenkins X.  For installation `jx` delegates to Helm (Kubernetes Package manager) for install, upgrades and uninstall operations.

Grab the latest [jx](https://github.com/jenkins-x/jx/releases/latest) and choose the type of cluster you want to create.
## Remote cluster install

The quickest way to get going is with [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/), other major cloud providers coming shortly.

__Prerequisite__ you will need a Google Cloud Account with a Google Project setup, follow this link for a free trial along with $300 credit https://console.cloud.google.com/freetrial

```
jx create cluster gke
```
And follow the CLI wizard

## Local development

For local development we can install Jenkins X with minikube.

First install the Hyperkit driver https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver

```
git clone https://github.com/jenkins-x/cloud-environments && cd cloud-environments
jx create cluster minikube --local-cloud-environment=true
```

## Accessing applications

You can list the external URLs used to access applications on your kubernetes cluster by running:
```
jx open
```

## Credentials

This repo is for test purposes, so default admin username and passwords are used:

| Application   | Username | Password |
| ------------- | -------- | -------- |
| K8S Dashboard | admin    | admin    |
| Chartmuseum   | admin    | admin    |
| Jenkins       | admin    | admin    |
| Nexus         | admin    | admin123 |
| Grafana       | admin    | admin    |

