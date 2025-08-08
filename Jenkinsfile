pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    SONAR_TOKEN        = credentials('SONAR_TOKEN')        // Secret Text
    NEXUS_CRED         = credentials('NEXUS_CRED')        // Username + Password
    NEXUS_DOCKER_REPO  = '15.206.80.6:5000/docker_dev'   // Nexus Docker repo (no http:// prefix)
    SONAR_HOST         = 'http://13.233.140.239:30002'      // SonarQube endpoint (no trailing slash)
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
        echo "Checking out branch: ${params.BRANCH_NAME}"
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/varaprasad070693/k8s.git']]
        ])
      }
    }

    stage('Check SonarQube') {
      steps {
        echo 'Checking SonarQube availability...'
        sh 'curl -s --fail $SONAR_HOST/api/system/status || { echo "SonarQube is unreachable!"; exit 1; }'
      }
    }

    stage('SonarQube Scan') {
      steps {
        echo 'Running SonarQube scan...'
        withSonarQubeEnv('MySonar') {
          sh """
            mvn clean verify sonar:sonar \\
              -Dsonar.projectKey=myproject \\
              -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \\
              -Dsonar.login=$SONAR_TOKEN
          """
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo 'Waiting for SonarQube Quality Gate...'
        timeout(time: 20, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Package') {
      steps {
        echo 'Building the project...'
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        echo 'Deploying artifact to Nexus...'
        withCredentials([usernamePassword(credentialsId: 'NEXUS_CRED', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          configFileProvider([configFile(fileId: '37ac4e82-23d9-4b4a-bbe0-dc83addc601a	', targetLocation: 'settings.xml')]) {
            sh """
              sed -i 's|<username>.*</username>|<username>$NEXUS_USER</username>|' settings.xml
              sed -i 's|<password>.*</password>|<password>$NEXUS_PASS</password>|' settings.xml
              mvn deploy -s settings.xml -DskipTests
            """
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo 'Building Docker image...'
        script {
          def image = "${env.NEXUS_DOCKER_REPO}/sonarqube-app:1.0.0-SNAPSHOT"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        echo 'Pushing Docker image to Nexus...'
        withCredentials([usernamePassword(credentialsId: 'NEXUS_CRED', usernameVariable: 'NEXUS_DOCKER_USR', passwordVariable: 'NEXUS_DOCKER_PSW')]) {
          script {
            def image = "${env.NEXUS_DOCKER_REPO}/sonarqube-app:1.0.0-SNAPSHOT"
            def registry = env.NEXUS_DOCKER_REPO.split('/')[0]
            sh """
              echo "$NEXUS_DOCKER_PSW" | docker login https://${registry} -u "$NEXUS_DOCKER_USR" --password-stdin
              docker push ${image}
              docker logout https://${registry}
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Full CI/CD pipeline succeeded.'
    }
    failure {
      echo 'Pipeline failed. Please check the logs.'
    }
  }
}
