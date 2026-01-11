pipeline {
  agent none

  options { timestamps() }

  environment {
    APP_PORT = "8085"
    POST_NODE_LABEL = "built-in"   // change to your node label if needed
  }

  stages {

    stage('Checkout') {
      agent { docker { image 'my-maven-git:latest'; reuseNode true } }
      steps { checkout scm }
    }

    stage('Build & Test') {
      agent { docker { image 'my-maven-git:latest'; reuseNode true } }
      steps { sh 'mvn -B clean test package' }
    }

    stage('Run (Smoke Test)') {
      agent { docker { image 'my-maven-git:latest'; reuseNode true } }
      steps {
        sh '''
          set -e
          java -jar target/*.jar --server.port=${APP_PORT} &
          APP_PID=$!
          sleep 8
          curl -fsS http://localhost:${APP_PORT}/ | grep "Bonjour"
          kill $APP_PID
        '''
      }
    }

    stage('Archive') {
      agent { docker { image 'my-maven-git:latest'; reuseNode true } }
      steps { archiveArtifacts artifacts: 'target/*.jar', fingerprint: true }
    }

    stage('Deploy (optionnel)') {
      when { branch 'main' }
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
      node('built-in') {
        withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
          sh """
            curl -sS -X POST -H 'Content-type: application/json' \
            --data-raw '{"text":"✅ SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}"}' \
            "$SLACK_WEBHOOK"
          """
        }
      }
    }
  
    failure {
      node('built-in') {
        withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
          sh """
            curl -sS -X POST -H 'Content-type: application/json' \
            --data-raw '{"text":"❌ FAILED: ${JOB_NAME} #${BUILD_NUMBER}"}' \
            "$SLACK_WEBHOOK"
          """
        }
      }
    }
  }

}
