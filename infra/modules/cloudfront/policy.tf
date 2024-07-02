# 各ポリシー置き場

# 長時間キャッシュする静的ファイル用
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# 一切キャッシュしないマネージドポリシー
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# resource "aws_cloudfront_cache_policy" "default" {
#   name        = "${var.service_name}-default-${var.env_short_name}"
#   comment     = "デフォルトキャッシュポリシー"
#   # CloudFront側ではデフォルトでキャッシュしない
#   default_ttl = 0
#   max_ttl     = 31536000
#   min_ttl     = 0

#   parameters_in_cache_key_and_forwarded_to_origin {
#     cookies_config {
#       cookie_behavior = "whitelist"
#       cookies {
#         items = []
#       }
#     }
#     headers_config {
#       header_behavior = "whitelist"
#       headers {
#         items = []
#       }
#     }
#     query_strings_config {
#       query_string_behavior = "allExcept"
#       query_strings {
#         items = concat()
#       }
#     }
#     enable_accept_encoding_brotli = true
#     enable_accept_encoding_gzip   = true
#   }
# }

resource "aws_cloudfront_cache_policy" "static" {
  name        = "common-${var.service_name}-static-short-${var.env_short_name}"
  comment     = "短時間キャッシュする静的ファイル用キャッシュポリシー"
  default_ttl = 60
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# オリジンリクエストポリシー
data "aws_cloudfront_origin_request_policy" "all_viewer_and_cloudfront" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}

# ヘッダ、クッキー、クエリパラメータにコード全部送る
resource "aws_cloudfront_origin_request_policy" "default" {
  name    = "common-${var.service_name}-default-${var.env_short_name}"
  comment = "${var.service_name}共通のオリジンリクエストポリシー"
  cookies_config {
    cookie_behavior = "all"
  }
  # CloudFront系ヘッダをfunctions内でも使いたい場合はオリジンリクエストポリシーに追記する。
  # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/example-function-redirect-url.html
  headers_config {
    header_behavior = "allViewerAndWhitelistCloudFront"
    headers {
      items = ["CloudFront-Viewer-Country", "CloudFront-Viewer-JA3-Fingerprint"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
