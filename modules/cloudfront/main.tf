resource "aws_s3_bucket" "my_bucket" {
  bucket        = "zura-task-bucket"
  force_destroy = true
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 bucket access"
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess",
        Effect    = "Allow",
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "index.html"
  content = <<-EOT
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My S3 & CloudFront Test Page</title>
  </head>
  <body>
    <h1>Welcome to My Test Page</h1>
    <p>
      This is a simple HTML page linked to an image hosted on S3 and served via
      CloudFront.
    </p>
    <p>
      Below is the image that was uploaded to my S3 bucket, and it's being
      served through CloudFront:
    </p>
    <img src="https://${aws_cloudfront_distribution.cdn.domain_name}/image.jpg" alt="Test Image" />

    <p>
      Feel free to explore other content linked to my CloudFront distribution!
    </p>
  </body>
</html>
EOT
content_type = "text/html"
}

resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "image.jpg"
  source = "${path.module}/image.jpg"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.my_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
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