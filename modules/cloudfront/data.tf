data "template_file" "index_html" {
  template = file("index.html.tmpl")

  vars = {
    cloudfront_domain = aws_cloudfront_distribution.cdn.domain_name
  }
}