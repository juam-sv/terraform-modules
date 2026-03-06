resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket = each.value.name
  tags   = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.buckets : k => v if try(v.versioning_enabled, false) }

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}
