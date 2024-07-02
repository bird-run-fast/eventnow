#----------------------------------------
# Cloudfront
#----------------------------------------

# cloudfront 関連かつ、各ディストリビューションで共通な設定を管理する

# oac は バケットごとに作ると管理しやすそう
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.service_name}-oac-${var.env_short_name}-for-${var.bucket_name}"
  description                       = "S3バケット:${var.bucket_name}へアクセスするためのOAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}