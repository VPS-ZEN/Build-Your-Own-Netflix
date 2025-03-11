# Build-Your-Own-Netflix
Build your own Netflix-like service with AWS S3, Elemental MediaConvert, ECS, and Cognito, all automated with Terraform.

## Prerequisites
- AWS account with CLI configured
- Terraform installed
- Docker installed
- GitHub account

## Setup

1. ### Clone the Repo
   ```bash
   git clone https://github.com/VPS-ZEN/Build-Your-Own-Netflix.git
   cd personal-media-streaming

2. ### Build and Push the Web App Docker Image
   ```bash
   cd web-app
   docker build -t personal-media-streaming .
   docker tag personal-media-streaming:latest your-ecr-repo/personal-media-streaming:latest
   docker push your-ecr-repo/personal-media-streaming:latest
   cd ..


3. ### Deploy with Terraform
Update terraform/variables.tf with your Docker image URL.
  ```bash
    cd terraform
    terraform init
    terraform apply
