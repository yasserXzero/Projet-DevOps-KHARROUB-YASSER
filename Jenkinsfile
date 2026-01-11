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
          set -e

          # if curl isn't in my-maven-git image, uncomment:
          # apt-get update && apt-get install -y curl

          java -jar target/*.jar --server.port=${APP_PORT} &
          APP_PID=$!
          sleep 8

          curl -fsS http://localhost:${APP_PORT}/ | grep "Bonjour"

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
          docker-compose down || true
          docker-compose up -d --build
        '''
      }
    }
  }

  post {
    success {
      node {
        withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
          sh '''
            curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"✅ SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}\"}" \
            "$SLACK_WEBHOOK"
          '''
        }
      }
    }

    failure {
      node {
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
}
