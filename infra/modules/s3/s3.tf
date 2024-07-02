#----------------------------------------
# S3 Bucket
#----------------------------------------
resource "aws_s3_bucket" "this" {
  for_each = { for i in var.s3_buckets : i.role => i }
  bucket   = "${each.value.service_name}-${each.value.env_short_name}-${each.value.role}"
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = { for i in var.s3_buckets : i.role => i }
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for i in var.s3_buckets : i.role => i }
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning
  }
}
