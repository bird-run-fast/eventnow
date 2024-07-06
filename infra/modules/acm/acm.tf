resource "aws_acm_certificate" "alb" {
  domain_name = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.alb.domain_validation_options : "${dvo.resource_record_name}"]
}


# 複数リージョンの ACM を apply しようとすると、重複する検証用レコード作成しようとしてエラーが発生する
# 今回は alb 用の ap-northeast-1 と, cloudfront 用の us-east-1 で作成する必要があったが
# 上記の課題を解消できなかったので、ACM検証用レコードに関しては IaC 管理から一旦外す

// ACMドメイン認証
# resource "aws_route53_record" "certificate_validation_alb" {
#   for_each = {
#     for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#     if strcontains(dvo.domain_name, "*")
#   }

#   name    = each.value.name
#   records = [each.value.record]
#   ttl     = 60
#   type    = each.value.type
#   zone_id = var.zone_id
# }
