
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.techeazy_instance.public_ip
}

output "bucket_name" {
  description = "S3 bucket for logs"
  value       = aws_s3_bucket.log_bucket.bucket
}
