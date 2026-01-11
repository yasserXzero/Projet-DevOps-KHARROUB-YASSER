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

          java -jar target/*.jar --server.port=${APP_PORT} &
          APP_PID=$!

          # wait a bit for startup
          sleep 8

          # smoke test
          curl -fsS "http://localhost:${APP_PORT}/" | grep "Bonjour"

          # cleanup
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

    stage('Deploy (optional)') {
      when {
        branch 'main'
      }
      agent any
      steps {
        sh '''
          set -e
          docker compose down || true
          docker compose up -d --build
        '''
      }
    }
  }

  post {
    success {
      script {
        notifySlack("✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
      }
    }
    failure {
      script {
        notifySlack("❌ FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
      }
    }
  }
}

def notifySlack(String msg) {
  withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
    sh """
      curl -sS -X POST -H 'Content-type: application/json' \
      --data '{\"text\":\"${msg}\"}' \
      "\$SLACK_WEBHOOK"
    """
  }
}
