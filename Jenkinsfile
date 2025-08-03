pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4' // Ensure this matches the name under Jenkins → Global Tool Configuration
  }

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN') // Must be stored as 'Secret text' in Jenkins credentials
  }

  parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch to build')
  }

  triggers {
    githubPush()
  }

  stages {

    stage('Checkout Code') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/varaprasad070693/k8s.git']]
        ])
      }
    }

    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('MySonar') {
          sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=myproject \
              -Dsonar.host.url=http://13.201.32.1:30002/ \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Package') {
      steps {
        sh 'mvn clean package'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }
  }

  post {
    success {
      echo ' Build, scan, and packaging successful.'
    }
    failure {
      echo ' Build or analysis failed.'
    }
  }
}
