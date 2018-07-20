CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := jenkins-x
OS := $(shell uname)
RELEASE_VERSION := $(shell jx-release-version)
HELM := helm

setup:
	$(HELM) repo add chartmuseum http://chartmuseum.build.cd.jenkins-x.io
	$(HELM) repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
	$(HELM) repo add stable https://kubernetes-charts.storage.googleapis.com
	$(HELM) repo add monocular https://helm.github.io/monocular

build: setup clean
	helm dependency build
	$(HELM) lint

install: clean setup build
	$(HELM) upgrade --install $(NAME) .

upgrade: clean setup build
	$(HELM) upgrade --install $(NAME) .

delete:
	$(HELM) delete --purge $(NAME)

clean: 
	rm -rf charts
	rm -rf ${NAME}*.tgz
	rm -rf requirements.lock

release: setup clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
else
	exit -1
endif
	git add Chart.yaml
	git commit -a -m "release $(RELEASE_VERSION)" --allow-empty
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)
	$(HELM) package .
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-platform-$(RELEASE_VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz
	updatebot push-version --kind make CHART_VERSION $(RELEASE_VERSION)
	echo $(RELEASE_VERSION) > VERSION
