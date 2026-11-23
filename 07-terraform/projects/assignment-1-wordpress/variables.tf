variable "aws_region" {
  description = "AWS region for the WordPress instance"
  type        = string
}

variable "ami_id" {
  description = "Official Ubuntu AMI ID for the selected region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}