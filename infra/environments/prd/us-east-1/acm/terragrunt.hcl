terraform {
  source = "../../../../modules//acm"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  domain_name = "00615.engineed-exam.com"
  zone_id = "Z095330321JIT9ESFYMQP"
}
