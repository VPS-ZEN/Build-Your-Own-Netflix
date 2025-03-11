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
```

3. ### Deploy with Terraform
Update terraform/variables.tf with your Docker image URL.
  ```bash
    cd terraform
    terraform init
    terraform apply
```

4. ### Upload and Transcode Videos
Upload a video to the raw_videos bucket (output from Terraform).

Create a MediaConvert job using the hls-720p template in the AWS Console.

Output will appear in the transcoded_videos bucket.

5. ### Access the Web App
Use the ECS service’s public IP (or set up an ALB) to visit the app.

Integrate Cognito for authentication (see outputs.tf for IDs).
