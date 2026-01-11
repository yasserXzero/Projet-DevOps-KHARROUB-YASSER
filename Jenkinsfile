pipeline {
  agent none

  options {
    timestamps()
  }

  environment {
    APP_PORT = "8085"
  }

  stages {

    stage('Checkout') {
      agent {
        docker {
          image 'my-maven-git:latest'
          reuseNode true
        }
      }
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      agent {
        docker {
          image 'my-maven-git:latest'
          reuseNode true
        }
      }
      steps {
        sh 'mvn -B clean test package'
      }
    }

    stage('Run (Smoke Test)') {
      agent {
        docker {
          image 'my-maven-git:latest'
          reuseNode true
        }
      }
      steps {
        sh '''
          java -jar target/*.jar --server.port=${APP_PORT} &
          APP_PID=$!
          sleep 8

          # Vérifie que l'app répond (nécessite curl dans l'image)
          curl -f http://localhost:${APP_PORT}/ | grep "Bonjour"

          kill $APP_PID
        '''
      }
    }

    stage('Archive') {
      agent {
        docker {
          image 'my-maven-git:latest'
          reuseNode true
        }
      }
      steps {
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Deploy (optionnel)') {
      when {
        branch 'main'
      }
      agent any
      steps {
        sh '''
          # Option 1 : si tu as déjà Dockerfile + docker-compose.yml dans ton repo
          # et que docker-compose est dispo sur le node Jenkins
          docker-compose down || true
          docker-compose up -d --build
        '''
      }
    }
  }

  post {
    success {
      withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
        sh '''
          curl -X POST -H 'Content-type: application/json' \
          --data "{\"text\":\"✅ SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}\"}" \
          "$SLACK_WEBHOOK"
        '''
      }
    }

    failure {
      withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
        sh '''
          curl -X POST -H 'Content-type: application/json' \
          --data "{\"text\":\"❌ FAILED: ${JOB_NAME} #${BUILD_NUMBER}\"}" \
          "$SLACK_WEBHOOK"
        '''
      }
    }
  }
}
