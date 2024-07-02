#----------------------------------------
# Cloudfront Distribution
#----------------------------------------

# ディストリビューションの設定項目が多いため、汎用的な module 化はきつい
# 各ディストリビューションごとにファイルを分離するほうが管理工数は減りそう
resource "aws_cloudfront_distribution" "static_00615_engineed_exam_com" {

  enabled          = "true"
  http_version     = "http2"
  is_ipv6_enabled  = "false"
  price_class      = "PriceClass_All"
  retain_on_delete = "false"
  wait_for_deployment = "true"

  aliases = var.cloudfront_distribution_aliases

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn

    ssl_support_method       = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }

  # Origin: App
  origin {
    domain_name              = var.app_alb_origin_domain_name
    origin_id                = "app-alb"
    origin_access_control_id = null
    origin_path              = null
    connection_attempts      = "3"
    connection_timeout       = "10"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  # Origin: Admin
  origin {
    domain_name              = var.admin_alb_origin_domain_name
    origin_id                = "admin-alb"
    origin_access_control_id = null
    origin_path              = null
    connection_attempts      = "3"
    connection_timeout       = "10"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  # Origin: Assets
  origin {
    domain_name              = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id                = var.bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    connection_attempts      = "3"
    connection_timeout       = "10"
  }

  # Behavior: App (デフォルト)
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id    
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "60"
    max_ttl                = "60"
    min_ttl                = "60"
    smooth_streaming       = "false"
    target_origin_id       = "app-alb"
    viewer_protocol_policy = "redirect-to-https"
  }

  # Behavior: Admin
  ordered_cache_behavior {
    allowed_methods            =  ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    field_level_encryption_id  = null
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer_and_cloudfront.id
    path_pattern               = "/admin/*"
    realtime_log_config_arn    = null
    smooth_streaming           = false
    target_origin_id           = "admin-alb"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"
  }

  # Behavior: Assets
  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.static.id
    cached_methods             = ["GET", "HEAD"]
    path_pattern               = "/assets/images/*"
    compress                   = true
    smooth_streaming           = false
    field_level_encryption_id  = null
    origin_request_policy_id   = null # s3の物を出したい時はHostヘッダを書き換えないようにする
    realtime_log_config_arn    = null
    target_origin_id           = "${var.bucket_name}"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
  }

  tags = {
    Name = "${var.resource_name_prefix}-${var.env_short_name}"
  }

  restrictions {
    geo_restriction { // 地理的制限
      restriction_type = "none"
    }
  }
}

