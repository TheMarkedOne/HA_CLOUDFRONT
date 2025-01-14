resource "aws_s3_bucket" "my_bucket" {
  bucket        = "zura-task-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*"
    }
  ]
}
POLICY
}

# Uploading HTML file to S3 with dynamic CloudFront domain
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "index.html"
  content = data.template_file.index_html.rendered
  acl    = "public-read"
}

# Uploading image file to S3
resource "aws_s3_bucket_object" "image" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "image.jpg"
  source = "./image.jpg"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.my_bucket.id
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.my_bucket.id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for S3 Bucket Website"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
