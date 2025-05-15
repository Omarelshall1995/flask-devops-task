# Flask DevOps Task

This repo shows how to deploy a Flask app using Docker, NGINX, Jenkins, and Terraform. Everything was done on an EC2 instance with manual setup and Let's Encrypt SSL.

---

## Setup Steps

### 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 2. Install NGINX

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 3. Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### Get Jenkins Password

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 4. Let Jenkins Use Docker

```bash
sudo usermod -aG docker jenkins
```

---

## Flask App

Simple Flask app that returns a basic message.

```python
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "test webhook"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## Dockerfile

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## NGINX Config

NGINX is used as a reverse proxy. Let's Encrypt was used to secure SSL.

```
server {
    listen 80;
    server_name 18.117.154.192.nip.io;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# HTTPS block after certbot
server {
    listen 443 ssl;
    server_name 18.117.154.192.nip.io;

    ssl_certificate /etc/letsencrypt/live/18.117.154.192.nip.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/18.117.154.192.nip.io/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Let's Encrypt Steps

```bash
sudo mkdir -p /var/www/certbot
# Add flask server block with /.well-known location
sudo ln -s /etc/nginx/sites-available/flask-ssl /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot certonly --webroot -w /var/www/certbot -d 18.117.154.192.nip.io
```

Same steps were repeated for Jenkins on port 8080 with a separate config.

---

## Jenkins CI/CD Pipeline

Pipeline builds image, pushes to DockerHub, and redeploys the container.

### Jenkinsfile

```groovy
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
                sh '''
                echo "$DOCKER_CREDENTIALS_PSW" | docker login -u "$DOCKER_CREDENTIALS_USR" --password-stdin
                docker push oshall95/flask-devops-task:latest
                '''
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
```

---

## Screenshots

![pipeline1](screenshots/pipeline1.png)
![pipeline2](screenshots/pipeline2.png)

---

## Terraform Setup

Terraform folder includes:

* main.tf
* variables.tf
* terraform.tfvars
* outputs.tf

```bash
terraform init
terraform import aws_instance.devops_vm i-0ebc8fcccb155df62
terraform plan
terraform apply
```

---

## Webhook Setup

Jenkins webhook URL:

```
https://jenkins.18.117.154.192.nip.io/github-webhook/
```

Enable webhook in GitHub repo settings and Jenkins job config.

---

## Final URLs (Let's Encrypt SSL)

```
https://18.117.154.192.nip.io/
https://jenkins.18.117.154.192.nip.io/
```

---

## Summary

The EC2 instance was provisioned and imported into Terraform. Docker, Jenkins, and NGINX were installed manually. A simple Flask app was containerized and deployed. Jenkins handled build and deployment automatically via webhook triggers. Let's Encrypt was used for SSL certificates instead of self-signed.
