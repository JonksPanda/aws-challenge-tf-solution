# Sets file to cv as variable
variable "filepath" {
  type    = string
  default = "./documents/CV-Jonathan_Friberg-SV.pdf"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "cv_bucket" {
  bucket = "cv-bucket-jf"

  tags = {
    Name = "CV Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "cv_bucket_ownership" {
  bucket = aws_s3_bucket.cv_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Removes public access block
resource "aws_s3_bucket_public_access_block" "cv_grant_acl" {
  bucket = aws_s3_bucket.cv_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Sets private acl on bucket
resource "aws_s3_bucket_acl" "cv_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cv_bucket_ownership]

  bucket = aws_s3_bucket.cv_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "my_cv" {
  bucket = aws_s3_bucket.cv_bucket.id
  key    = "cv.pdf"
  source = var.filepath
  acl    = "public-read"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.filepath)
}
