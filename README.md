# Jenkins X Helm Charts

[Jenkins X](https://jenkins-x.github.io/jenkins-x-website/) is an integrated CI / CD platform for any Kubernetes cluster or cloud.  Simple installation of best of bread open source software for developing and running applications in the cloud.

What's in the box?

|                                   |                                       |
| --------------------------------- | ------------------------------------- |
|![Jenkins](./images/jenkins.png)   | __Jenkins__ - Fully integrated CI / CD solution with opinionated yet customisable pielines and environments |
|![Sonartype Nexus 3](./images/nexus.png) | __Nexus__ Artifact repository (pluggable so we can switch with Artifactory) |
|![Chartmuseum](./images/chartmuseum.png) | __Chartmuseum__ Helm Chart repository (Helm is the most popular Kubernetes package manager used to install and upgrade your applications)|
|![Monocular](./images/bitnami.png) | __Monocular__ Web UI for searching and discovering Helm Charts |

Monitoring and alerting projects to come.

## Remote cluster install

If you are installing on a remote Kubernetes cluster, head over to the cloud environments repo which includes entire environments that install out of the box, preconfigured for you cloud provider with [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/) and [Azure Container Service (AKS)](https://azure.microsoft.com/en-gb/services/container-service/), [Amazon Elastic Container Service (EKS)](https://aws.amazon.com/eks/) to come shortly.

https://github.com/jenkins-x/cloud-environments


## Local development

Best way to get started is with minikube.

These steps are for OSX for others OS please see the docs https://github.com/kubernetes/minikube#installation.

First install the Hyperkit driver https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver

Next get minikube
```
brew cask install minikube
```

This repo has some helper commands to get you started

```
git clone https://github.com/jenkins-x/jenkins-x-platfrom && cd jenkins-x-platfrom
minikube start --vm-driver hyperkit --cpus 4 --memory 4096
```
We use `helm` as the package manager and install / upgrade features so to get the binary and install an nginx ingress controller so we can access our apps run:
```
make setup
```
to install Jenkins-X on minikube:
```
make install
```
now you can edit charts and apply the chages using:
```
make upgrade
```
to clean up run:
```
make delete
```

## Accessing applications

You can list the external URLs used to acess applications on you kubernetes cluster by running:
```
kubectl get ingress
```

## Credentials

This repo is for test purposes so default admin username and passwords are used:

| Application | Username | Password |
| ----------- | -------- | -------- |
| Jenkins     | admin    | admin    |
| Nexus       | admin    | admin123 |
