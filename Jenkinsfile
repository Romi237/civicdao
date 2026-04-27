// CivicDAO — Jenkinsfile
// CI/CD pipeline: runs on every push to main or develop
// Stages: Checkout → Install → Lint → Test → Docker Build → Push → Deploy

pipeline {
  agent any

  environment {
    APP_NAME = 'civicdao'
    DOCKER_REGISTRY = 'registry.civicdao.org'
    IMAGE_NAME = "${DOCKER_REGISTRY}/${APP_NAME}/backend"
    K8S_NAMESPACE = 'civicdao'
    IMAGE_TAG = "${env.BRANCH_NAME}-${env.GIT_COMMIT[0..6]}-${env.BUILD_NUMBER}"
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
  }

  stages {

    stage('Checkout') {
      steps {
        echo 'Checking out source code...'
        checkout scm
        sh 'git log --oneline -3'
      }
    }

    stage('Install Dependencies') {
      parallel {
        stage('Backend') {
          steps {
            dir('backend') {
              echo 'Installing Node.js dependencies...'
              sh 'npm ci'
            }
          }
        }
        stage('Flutter') {
          steps {
            echo 'Installing Flutter dependencies...'
            sh 'flutter pub get'
          }
        }
      }
    }

    stage('Lint and Analyse') {
      parallel {
        stage('Flutter analyse') {
          steps {
            sh 'flutter analyze --no-fatal-infos'
          }
        }
        stage('Backend audit') {
          steps {
            dir('backend') {
              sh 'npm audit --audit-level=high || true'
            }
          }
        }
      }
    }

    stage('Tests') {
      parallel {
        stage('Flutter tests') {
          steps {
            sh 'flutter test --coverage'
          }
          post {
            always {
              publishHTML(target: [
                allowMissing: true,
                reportDir: 'coverage/html',
                reportFiles: 'index.html',
                reportName: 'Flutter Coverage'
              ])
            }
          }
        }
        stage('Backend tests') {
          steps {
            dir('backend') {
              sh 'npm test'
            }
          }
        }
      }
    }

    stage('Docker Build') {
      when {
        anyOf {
          branch 'main'
          branch 'develop'
        }
      }
      steps {
        echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
        script {
          docker.build("${IMAGE_NAME}:${IMAGE_TAG}", "-f Dockerfile .")
          docker.build("${IMAGE_NAME}:latest", "-f Dockerfile .")
        }
      }
    }

    stage('Push Image') {
      when {
        anyOf {
          branch 'main'
          branch 'develop'
        }
      }
      steps {
        script {
          docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-creds') {
            docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
            docker.image("${IMAGE_NAME}:latest").push()
          }
        }
      }
    }

    stage('Deploy to Staging') {
      when {
        branch 'develop'
      }
      steps {
        withKubeConfig([credentialsId: 'k8s-staging']) {
          sh """
            kubectl set image deployment/civicdao-backend \
              civicdao-backend=${IMAGE_NAME}:${IMAGE_TAG} \
              -n ${K8S_NAMESPACE}-staging

            kubectl rollout status deployment/civicdao-backend \
              -n ${K8S_NAMESPACE}-staging --timeout=120s
          """
        }
      }
    }

    stage('Deploy to Production') {
      when {
        branch 'main'
      }
      input {
        message "Deploy to PRODUCTION?"
        ok "Yes, deploy"
        submitter "admin"
      }
      steps {
        withKubeConfig([credentialsId: 'k8s-prod']) {
          sh """
            kubectl set image deployment/civicdao-backend \
              civicdao-backend=${IMAGE_NAME}:${IMAGE_TAG} \
              -n ${K8S_NAMESPACE}

            kubectl rollout status deployment/civicdao-backend \
              -n ${K8S_NAMESPACE} --timeout=180s
          """
        }
      }
    }
  }

  post {
    success {
      echo "Build #${env.BUILD_NUMBER} passed on ${env.BRANCH_NAME}"
    }
    failure {
      echo "Build #${env.BUILD_NUMBER} FAILED on ${env.BRANCH_NAME}"
    }
    always {
      cleanWs()
    }
  }
}