variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "docker_image" {
  description = "Docker image for the web app (e.g., your ECR repository URL)"
  type        = string
}