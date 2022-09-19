#Create S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket_name}"
}

#Create S3 ACL 
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "${var.s3_acl}"
}
#lock down S3 bucket no public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = "${var.block_public_acls}"
  block_public_policy     = "${var.block_public_policy}"
  ignore_public_acls      = "${var.block_public_acls}"
  restrict_public_buckets = "${var.restrict_public_buckets}"
}
#Enable bucket versisiong 
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
#Create kms key
resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 30
}
#enable S3 bucket encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encrypt" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
#Create 2 folders in S3 bucket
resource "aws_s3_object" "folder" {
  # Must have bucket created first
  depends_on = [aws_s3_bucket.bucket]
  
  count  = "${length(var.s3_folders)}"
  key    = "${var.s3_folders[count.index]}/"
  bucket = aws_s3_bucket.bucket.id
}
#Create policy for s3 bucket
resource "aws_s3_bucket_lifecycle_configuration" "bucket_images" {
  depends_on = [aws_s3_bucket.bucket]

  bucket = aws_s3_bucket.bucket.bucket
  #Rule move to objects in Images after 90 days to glacier
  rule {
    id = "image-move"

    filter {
        prefix = "Images/"
    }

    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  #Rule move to objects in Logs after 90 days to be deleted
  rule {
    id = "log-delete"

    filter {
        prefix = "Logs/"
    }

    status = "Enabled"
    
    expiration {
      days = 90
    }
  }
}

