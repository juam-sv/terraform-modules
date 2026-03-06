resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = each.value.name
  description             = try(each.value.description, null)
  recovery_window_in_days = try(each.value.recovery_window_in_days, 30)

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = { for k, v in var.secrets : k => v if try(v.secret_string, null) != null }

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.secret_string
}
