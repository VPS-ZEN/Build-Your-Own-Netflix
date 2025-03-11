# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# S3 Buckets
resource "aws_s3_bucket" "raw_videos" {
  bucket = "my-media-raw-${random_string.suffix.result}"
  acl    = "private"
}

resource "aws_s3_bucket" "transcoded_videos" {
  bucket = "my-media-transcoded-${random_string.suffix.result}"
  acl    = "private"
}

# VPC and Networking (simplified for ECS)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "media_app" {
  name = "media-streaming-cluster"
}

resource "aws_ecs_task_definition" "web_app" {
  family                   = "media-web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "web-app"
    image = "${var.docker_image}:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    environment = [
      { name = "S3_BUCKET", value = aws_s3_bucket.transcoded_videos.bucket },
      { name = "AWS_REGION", value = var.aws_region }
    ]
  }])
}

resource "aws_ecs_service" "web_service" {
  name            = "media-web-service"
  cluster         = aws_ecs_cluster.media_app.id
  task_definition = aws_ecs_task_definition.web_app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Simplified; use a load balancer in production
  }
}

# MediaConvert Job Template
resource "aws_media_convert_job_template" "hls_template" {
  name = "hls-720p"
  settings_json = jsonencode({
    "OutputGroups": [{
      "Name": "Apple HLS",
      "Outputs": [{
        "Preset": "System-Generic_Hd_Mp4_Avc_Aac_16x9_1280x720p_24Hz_4.5Mbps",
        "NameModifier": "_720p"
      }],
      "OutputGroupSettings": {
        "Type": "HLS_GROUP_SETTINGS",
        "HlsSettings": {
          "SegmentLength": 10
        }
      }
    }],
    "Inputs": [{
      "FileInput": "s3://${aws_s3_bucket.raw_videos.bucket}/{input_file}"
    }]
  })
}

# Cognito User Pool
resource "aws_cognito_user_pool" "media_users" {
  name = "media-streaming-users"
  password_policy {
    minimum_length = 8
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = "media-web-client"
  user_pool_id = aws_cognito_user_pool.media_users.id
}