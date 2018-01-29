pipeline {
    environment {
        CHARTMUSEUM_CREDS = credentials('jenkins-x-github')
        GH_CREDS = credentials('jenkins-x-chartmuseum')
    }
    agent {
        label "jenkins-jx-base"
    }
    stages {
        stage('CI Build') {
            when {
                branch 'PR-*'
            }
            steps {
                dir ('/home/jenkins/jenkins-x-platform') {
                    checkout scm
                    container('jx-base') {
                        sh "helm init --client-only"
                        sh "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com"
                        sh "helm repo add stable https://kubernetes-charts.storage.googleapis.com"
                        sh "helm repo add monocular https://kubernetes-helm.github.io/monocular"
                        sh "helm repo add chartmuseum http://chartmuseum.thunder.thunder.fabric8.io"
                        sh "helm repo add jx http://chartmuseum.cd.thunder.fabric8.io"
                        sh "make build"
                        sh "helm template ."
                    }
                }
            }
        }
    
        stage('Build and Push Release') {
            when {
                branch 'master'
            }
            steps {
                dir ('/home/jenkins/jenkins-x-platform') {
                    checkout scm
                    container('jx-base') {
                        // until kubernetes plugin supports init containers https://github.com/jenkinsci/kubernetes-plugin/pull/229/
                        sh 'cp /root/netrc/.netrc ~/.netrc'

                        sh "git checkout master"
                        sh "helm init --client-only"
                        sh "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com"
                        sh "helm repo add stable https://kubernetes-charts.storage.googleapis.com"
                        sh "helm repo add monocular https://kubernetes-helm.github.io/monocular"
                        sh "helm repo add chartmuseum http://chartmuseum.thunder.thunder.fabric8.io"
                        sh "helm repo add jx http://chartmuseum.cd.thunder.fabric8.io"
                        sh "make release"
                    }
                }
            }
        }
    }
}
