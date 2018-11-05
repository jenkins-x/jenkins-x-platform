#!/usr/bin/env bash

# ensure we're not on a detached head
git checkout master

# until we switch to the new kubernetes / jenkins credential implementation use git credentials store
git config credential.helper store

helm init --client-only
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add monocular https://kubernetes-helm.github.io/monocular
helm repo add jx http://chartmuseum.jenkins-x.io
make release
