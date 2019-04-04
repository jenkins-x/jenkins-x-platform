CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := jenkins-x
OS := $(shell uname)
RELEASE_VERSION := $(shell jx-release-version)
HELM := helm

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init:
	$(HELM) init --client-only

setup: init
	$(HELM) repo add jx http://chartmuseum.jenkins-x.io
	$(HELM) repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
	$(HELM) repo add stable https://kubernetes-charts.storage.googleapis.com
	$(HELM) repo add monocular https://helm.github.io/monocular

build: setup clean
	$(HELM) dependency build jenkins-x-platform
	$(HELM) lint jenkins-x-platform

lint:
	$(HELM) dependency build jenkins-x-platform
	$(HELM) lint jenkins-x-platform

install: clean setup build
	$(HELM) upgrade --debug --install $(NAME) .

apply: clean setup
	jx step helm apply $(NAME) .

upgrade: clean setup build
	$(HELM) upgrade --debug --install $(NAME) .

delete:
	$(HELM) delete --purge $(NAME)

clean: 
	rm -rf jenkins-x-platform/charts
	rm -rf jenkins-x-platform/${NAME}*.tgz
	rm -rf jenkins-x-platform/requirements.lock

release: setup clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(RELEASE_VERSION)/" jenkins-x-platform/Chart.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(RELEASE_VERSION)/" jenkins-x-platform/Chart.yaml
else
	exit -1
endif
	git add jenkins-x-platform/Chart.yaml
	git commit -a -m "release $(RELEASE_VERSION)" --allow-empty
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)
	$(HELM) package jenkins-x-platform
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-platform-$(RELEASE_VERSION).tgz" $(CHART_REPO)/api/charts
	helm repo update
	rm -rf ${NAME}*.tgz
	updatebot push-version --kind make CHART_VERSION $(RELEASE_VERSION)
	updatebot push-regex -r "JX_PLATFORM_VERSION=(.*)" -v $(RELEASE_VERSION) build.sh
	jx step create version pr -f "jenkins-x/*" -b --images
	echo $(RELEASE_VERSION) > VERSION
