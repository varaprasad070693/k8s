pipeline {
    agent { label'docker' }

    environment {
        DOCKER_REPO_CREDENTIALS = '7aaafea6-7662-43fd-975a-fae773d06447'
        DOCKER_IMAGE = 'varaprasadmp/vp'          
        GIT_REPO = 'https://github.com/varaprasad070693/docker'
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
                    COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    IMAGE_TAG_COMMIT = "${DOCKER_IMAGE}:${COMMIT_HASH}"
                    IMAGE_TAG_LATEST = "${DOCKER_IMAGE}:latest"

                    echo "Building Docker image with tags: ${IMAGE_TAG_COMMIT} and ${IMAGE_TAG_LATEST}"
                    sh "docker build -t ${IMAGE_TAG_COMMIT} -t ${IMAGE_TAG_LATEST} ."
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
                    echo "IMAGE_TAG_COMMIT: ${IMAGE_TAG_COMMIT}"
                    echo "IMAGE_TAG_LATEST: ${IMAGE_TAG_LATEST}"
                    sh "docker push ${IMAGE_TAG_COMMIT}"
                    sh "docker push ${IMAGE_TAG_LATEST}"
                }
            }
        }
    }

    post {
        success {
            echo " Build and push completed successfully!"
        }
        failure {
            echo " Build or push failed. Check logs for details."
        }
        always {
            echo " Build finished: ${currentBuild.currentResult}"
        }
    }
}
