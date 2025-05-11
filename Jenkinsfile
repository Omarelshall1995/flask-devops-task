pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub')
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Omarelshall1995/flask-devops-task.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t oshall95/flask-devops-task:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh """
                echo "$DOCKER_CREDENTIALS_PSW" | docker login -u "$DOCKER_CREDENTIALS_USR" --password-stdin
                docker push oshall95/flask-devops-task:latest
                """
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker rm -f flask-container || true'
                sh 'docker run -d --name flask-container -p 5000:5000 oshall95/flask-devops-task:latest'
            }
        }
    }
}

