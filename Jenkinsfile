
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        KUBECONFIG = credentials('kubeconfig-creds')
    }

    stages {
        stage('Setup') {
            steps {
                sh 'chmod +x steps.sh'
                sh './steps.sh'

                sh 'chmod 644 $KUBECONFIG'
                sh 'kubectl config get-contexts'
            }
        }

        stage('Test') {
            steps {
                sh 'bash -c "source app/env/bin/activate && pytest test_app.py"'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_TAG} .'
                echo "Docker image built successfully: ${IMAGE_TAG}"
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login --username $DOCKER_USER --password-stdin <<< "$DOCKER_PASSWORD"'
                        echo "Logged into DockerHub successfully."
                        
                        sh 'docker push ${IMAGE_TAG}'
                    }          
                }
                echo "Docker image pushed successfully to DockerHub."
            }
        }


        stage('Deploy to Staging') {
            steps {
                script {
                    sh "kubectl config use-context staging-context"
                    sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG}"
                }
            }
        }

        stage('Acceptance Test in Staging') {
            steps {
                script {

                    def service = sh(script: "kubectl get svc flask-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}:{.spec.ports[0].port}'", returnStdout: true).trim()
                    echo "${service}"

                    sh "k6 run -e SERVICE=${service} acceptance-test.js"
                }
            }
        }

        stage('Deploy to Production') {
            steps {
               script {
                    sh "kubectl config use-context production-context"
                    sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG}"
                }  
            }    
        }
    }

    post {
        cleanup {
            sh 'docker system prune -f'
            sh 'rm -rf ~/.kube/cache || true'
        }
    }

}
