output "raw_bucket_name" {
  value = aws_s3_bucket.raw_videos.bucket
}

output "transcoded_bucket_name" {
  value = aws_s3_bucket.transcoded_videos.bucket
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.media_users.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}