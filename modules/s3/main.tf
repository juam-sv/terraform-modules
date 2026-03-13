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

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = each.value.kms_key_id
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  for_each = { for k, v in var.buckets : k => v if v.logging_target_bucket != null }

  bucket = aws_s3_bucket.this[each.key].id

  target_bucket = each.value.logging_target_bucket
  target_prefix = each.value.logging_target_prefix
}
