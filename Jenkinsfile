pipeline {
    agent any
    environment {
        CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
        stage('CI Build') {
            when {
                branch 'PR-*'
            }
            steps {
                dir ('/home/jenkins/jenkins-x-platform') {
                    checkout scm
                    sh "helm init --client-only"

                    sh "make build"
                    sh "helm template ."
                }
            }
        }

        stage('Build and Push Release') {
            when {
                branch 'master'
            }
            steps {
                dir ('/home/jenkins/jenkins-x-platform') {
                    git "https://github.com/jenkins-x/jenkins-x-platform"
                    
                    sh "jx step git credentials"
                    sh "./jx/scripts/release.sh"
                }
                dir('/home/jenkins/packs'){
                    git 'https://github.com/jenkins-x/draft-packs.git'
                    sh 'git config credential.helper store'
                    sh "jx step git credentials"
                    sh 'jx step tag --version \$(cat /home/jenkins/jenkins-x-platform/VERSION)'
                }
            }
        }
    }
}
