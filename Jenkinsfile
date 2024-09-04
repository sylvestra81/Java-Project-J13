pipeline {
    agent any
    tools {
        maven 'maven'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        stage('Build Maven') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/sylvestra81/Java-Project-J13']])
                sh 'mvn clean install'
            }
        }
        stage('File system scan with Trivy') {
            steps {
                sh 'trivy fs --format table -o trivy-fs-report.html .'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Java-Project-J13 -Dsonar.projectKey=Java-Project-J13 \
                            -Dsonar.java.binaries=. '''
               }
            }
        }
        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }
        stage('Compile and Deploy artifact to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-settings', jdk: '', maven: 'maven', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }
        stage('Build docker image') {
            steps {
                script {
                    sh 'docker build -t sylvestra/project-j13 .'
                }
            }
        }
        stage('Docker Image scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html sylvestra/project-j13"
            }
        }
        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'sylvestra', variable: 'mydockerpwd')]) {
                        sh 'docker login -u sylvestra -p ${mydockerpwd}'
                    }
                }
            }
        }
        stage('Push image to Docker Hub') {
            steps {
                script {
                    sh 'docker push sylvestra/project-j13'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.27.74:6443') {
                    script {
                        sh 'kubectl apply -f deployment-service.yaml'
                    }
                }
            }
        }
        stage('Verify the deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.27.74:6443') {
                    script {
                        sh 'kubectl get pods -n webapps'
                        sh 'kubectl get svc -n webapps'
                    }
                }
            }
        }
    }
}