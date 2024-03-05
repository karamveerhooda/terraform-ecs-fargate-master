/*cloudtrail


resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "aiops-cloudtrail-log9999"
  #acl    = "private"
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

resource "aws_cloudtrail" "example" {
  name                          = "AIOPS-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
                              
  cloud_watch_logs_group_arn = data.aws_cloudwatch_logs_log_group.AIOPS_log_group.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

/*resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/cloudtrail/example-trail"
  retention_in_days = 365
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
*/