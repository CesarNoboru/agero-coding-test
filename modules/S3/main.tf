# SOURCE S3
resource "aws_s3_bucket" "source_bucket" {
    bucket          = join("-", [var.prefix_bucket_name, "source"])
    force_destroy   = true
}

resource "aws_s3_bucket_ownership_controls" "source_bucket_control" {
    bucket          = aws_s3_bucket.source_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "source_bucket_acl" {
  depends_on            = [aws_s3_bucket_ownership_controls.source_bucket_control]

  bucket                = aws_s3_bucket.source_bucket.id
  acl                   = "private"
}

# DESTINATION S3
resource "aws_s3_bucket" "destination_bucket" {
    bucket          = join("-", [var.prefix_bucket_name, "destination"])
    force_destroy   = true
}

resource "aws_s3_bucket_ownership_controls" "destination_bucket_control" {
    bucket = aws_s3_bucket.destination_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "destination_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.destination_bucket_control]

  bucket = aws_s3_bucket.destination_bucket.id
  acl    = "private"
}