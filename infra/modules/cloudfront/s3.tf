#----------------------------------------
# S3 Bucket
#----------------------------------------

# cloudfront 経由で配信する assets 用のバケット
resource "aws_s3_bucket" "assets" {
  bucket =  "${var.bucket_name}"
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#----------------------------------------
# S3 Bucket Policy
#----------------------------------------

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  policy = templatefile("./bucket_policy.json.tpl", {
    bucket_name    = "${var.bucket_name}",
    cloudfront_arn = resource.aws_cloudfront_distribution.static_00615_engineed_exam_com.arn
  })
}
