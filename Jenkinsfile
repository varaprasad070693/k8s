pipeline {
    agent { label'docker' }

    environment {
        DOCKER_REPO_CREDENTIALS = 'd7c71435-4e54-456a-93b1-51a4f2935613'
        DOCKER_IMAGE = 'varaprasadmp/k8s'          
        GIT_REPO = 'https://github.com/varaprasad070693/k8s'
        BRANCH = 'main'
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo "Cloning repository from ${GIT_REPO}"
                git branch: "${BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG_LATEST = "${DOCKER_IMAGE}:latest"
                    echo "Building Docker image with tags: ${IMAGE_TAG_LATEST}"
                    sh "docker build -t ${IMAGE_TAG_LATEST} ."
                }
            }
        }

        stage('Authenticate with Docker Registry') {
            steps {
                script {
                    echo "Logging in to Docker registry"
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REPO_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    echo "Pushing images to registry"
                    echo "IMAGE_TAG_LATEST: ${IMAGE_TAG_LATEST}"
                    sh "docker push ${IMAGE_TAG_LATEST}"
                }
            }
        }
    }

    post {
        success {
            echo " Deployed Successfully!"
        }
        failure {
            echo " Deployment failed"
        }
        
    }
}
