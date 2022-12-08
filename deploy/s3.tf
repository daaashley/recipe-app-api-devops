resource "aws_s3_bucket" "app_public_files" {
  bucket        = "${local.prefix}-files-devops-david-1"
  acl           = "public-read"
  force_destroy = true
}
