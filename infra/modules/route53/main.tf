# module "zones" {
#   source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "3.1.0"

#   zones = {
#     "00615.engineed-exam.com " = {
#       comment = "00615.engineed-exam.com  (${var.env_name})"
#       tags = {
#         env = "${var.env_name}"
#       }
#     }
#   }
# }

# module "records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "3.1.0"

#   zone_name = keys(module.zones.route53_zone_zone_id)[0]

#   records = [
#     {
#       name    = "XXX"
#       type    = "A"
#       ttl     = 3600
#       records = [
#         "10.10.10.10",
#       ]
#     },
#   ]

#   depends_on = [module.zones]
# }