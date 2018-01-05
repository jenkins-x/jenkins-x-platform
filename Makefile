CHART_REPO := http://chartmuseum.thunder.thunder.fabric8.io
NAME := jenkins-x
OS := $(shell uname)
RELEASE_VERSION := ''# $(shell semver-release-version)
HELM := $(shell command -v helm 2> /dev/null)
WATCH := $(shell command -v watch --help 2> /dev/null)
IP := $(shell minikube ip)
INGRESS_RUNNING := $(shell minikube addons list | grep "ingress: enabled" 2> /dev/null)
HEAPSTER_RUNNING := $(shell minikube addons list | grep "heapster: enabled" 2> /dev/null)
TILLER_RUNNING := $(shell kubectl get pod -l app=helm -l name=tiller -n kube-system | grep '1/1       Running' 2> /dev/null)

setup:

# setup is always called from the `clean` target, remove it not required to run each time
# this will check dependencies are installed, services are running and local repos configured correctly
ifndef HELM
ifeq ($(OS),Darwin)
	brew install kubernetes-helm
else
	echo "Please install helm first https://github.com/kubernetes/helm/blob/master/docs/install.md"
endif
endif

ifndef WATCH
ifeq ($(OS),Darwin)
	brew install watch
else
	echo "Please install watch first"
endif
endif

ifndef TILLER_RUNNING
	helm init
	echo 'Waiting for tiller to become available in the namespace kube-system'
	(kubectl get pod -l app=helm -l name=tiller -n kube-system -w &) | grep -q  '1/1       Running'
endif

ifndef INGRESS_RUNNING
	minikube addons enable ingress
	echo 'Waiting for the ingress controller to become available in the namespace kube-system'
	(kubectl get pod -l app=nginx-ingress-controller -l name=nginx-ingress-controller -n kube-system -w &) | grep -q  '1/1       Running'
endif

ifndef HEAPSTER_RUNNING
	minikube addons enable heapster
	echo 'Waiting for heapster to become available in the namespace kube-system'
	(kubectl get pod -l k8s-app=heapster -n kube-system -w &) | grep -q  '1/1       Running'
endif

	helm repo add chartmuseum $(CHART_REPO)
	helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
	helm repo add stable https://kubernetes-charts.storage.googleapis.com
	helm repo add monocular https://kubernetes-helm.github.io/monocular

build: clean
	rm -rf requirements.lock
	helm dependency build
	helm lint

install: clean build
	helm install . --name $(NAME)
	minikube dashboard
	watch kubectl get pods

upgrade: clean build
	helm upgrade $(NAME) .
	watch kubectl get pods

delete:
	helm delete --purge $(NAME)

clean: setup
	rm -rf charts
	rm -rf ${NAME}*.tgz

release: clean
	helm dependency build
	helm lint
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
else ifeq ($(OS),Linux)
	echo "linux"
else
	exit -1
endif
	git add Chart.yaml
	git commit -a -m "release $(RELEASE_VERSION)"
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)
	helm package .
	curl --data-binary "@$(NAME)-platform-$(RELEASE_VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz