locals {
  s3_origin_id = "${var.bucket_name}-origin"
}

resource "aws_cloudfront_origin_access_control" "default" {
  description                       = "Restrict access to S3 bucket ${var.bucket_name}"
  name                              = "oac_${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  default_cache_behavior {

    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.add_index_html.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [1] : []

    content {
      acm_certificate_arn            = var.acm_certificate_arn
      cloudfront_default_certificate = false
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == "" ? [1] : []

    content {
      cloudfront_default_certificate = true

    }
  }

  aliases = var.custom_domain_names


  price_class = "PriceClass_100"

}

resource "aws_cloudfront_function" "add_index_html" {
  name    = "add-index-html-${var.bucket_name}"
  runtime = "cloudfront-js-1.0"
  comment = "Appends index.html to directory requests"

  code = <<EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } else if (!uri.includes('.') && !uri.endsWith('/')) {
        request.uri += '/index.html';
    }

    return request;
}
EOF
}
