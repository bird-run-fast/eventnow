#----------------------------------------
# SSM Parameter Store
#----------------------------------------

resource "aws_ssm_parameter" "web-image-tag" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/WEB_IMAGE_TAG"
  type  = "String"
  value = "latest"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "app-image-tag" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/APP_IMAGE_TAG"
  type  = "String"
  value = "latest"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_HOST"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_PORT"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_database" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_DATABASE"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_USERNAME"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_PASSWORD"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "redis_host" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/REDIS_HOST"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "aws_bucket" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/AWS_BUCKET"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "aws_url" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/AWS_URL"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "assets_endpoint" {
  name  = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/ASSETS_ENDPOINT"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

