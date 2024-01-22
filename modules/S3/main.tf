resource "aws_s3_bucket" "s3_bucket" {
    for_each        = toset(var.suffix_bucket_name)
    bucket          = join("-", [var.prefix_bucket_name, each.value])
    force_destroy   = true
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_control" {
    depends_on              = [aws_s3_bucket.s3_bucket]
    for_each                = aws_s3_bucket.s3_bucket
    bucket                  = aws_s3_bucket.s3_bucket[each.key].id
    rule {
        object_ownership    = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
    depends_on            = [aws_s3_bucket_ownership_controls.s3_bucket_control]
    for_each              = aws_s3_bucket.s3_bucket
    bucket                = aws_s3_bucket.s3_bucket[each.key].id
    acl                   = "private"
}