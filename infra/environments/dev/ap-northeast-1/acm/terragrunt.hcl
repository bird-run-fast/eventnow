terraform {
  source = "../../../../modules//acm"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  domain_name = "dev.00615.engineed-exam.com"
}
