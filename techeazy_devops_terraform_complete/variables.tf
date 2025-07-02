
variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-0447a12f28fddb066"
}

variable "repo_url" {
  description = "GitHub repo URL"
  default     = "https://github.com/techeazy-consulting/techeazy-devops.git"
}

variable "bucket_name" {
  description = "S3 bucket name for logs"
}

variable "shutdown_after_minutes" {
  description = "Minutes before shutdown"
  default     = 30
}

variable "key_name" {
  description = "AWS key pair name"
}
