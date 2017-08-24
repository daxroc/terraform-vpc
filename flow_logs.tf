resource "aws_flow_log" "vpc_flowlog" {
  count          = "${var.enable_flowlog > 0 ? 1 : 0 }"
  log_group_name = "${aws_cloudwatch_log_group.flowlog_group.name}"
  iam_role_arn   = "${aws_iam_role.flowlog_role.arn}"
  vpc_id         = "${aws_vpc.default.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "flowlog_group" {
  name  = "${var.name}-vpc"
  count = "${var.enable_flowlog > 0 ? 1 : 0 }"
  retention_in_days = "${var.cloudwatch_retention_in_days}"
  tags   = "${merge(var.tags, map("Name", format("%s-vpc", var.name)))}"
}

resource "aws_cloudwatch_log_subscription_filter" "flow_logs" {
  name            = "${aws_cloudwatch_log_group.flowlog_group.name}_to_lambda"
  count           = "${var.enable_flowlog > 0 ? 1 : 0 }"
  log_group_name  = "${aws_cloudwatch_log_group.flowlog_group.name}"
  filter_pattern  = "${var.flow_log_filter}"
  destination_arn = "${aws_kinesis_stream.vpc_stream.arn}"
  role_arn        = "${aws_iam_role.flowlog_subscription_role.arn}"
}

resource "aws_kinesis_stream" "vpc_stream" {
  name             = "${var.name}-vpc-stream"
  count            = "${var.enable_flowlog > 0 ? 1 : 0 }"
  shard_count      = 64
  retention_period = 48

  tags   = "${merge(var.tags, map("Name", format("%s-vpc-stream", var.name)))}"

}


resource "aws_iam_role" "flowlog_role" {
  name               = "${var.name}_flow_log_role"
  count              = "${var.enable_flowlog > 0 ? 1 : 0 }"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy" "flowlog_write" {
  name   = "${var.name}_write_to_cloudwatch"
  role   = "${aws_iam_role.flowlog_role.id}"
  count  = "${var.enable_flowlog > 0 ? 1 : 0 }"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}   
EOF
}

// Allow log subscription to write to Kinesis Stream
// http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html

resource "aws_iam_role" "flowlog_subscription_role" {
  name               = "${var.name}_flow_log_subscription_role"
  count              = "${var.enable_flowlog > 0 ? 1 : 0 }"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.region}.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy" "flowlog_kinesis_wo" {
  name   = "${var.name}_write_flow_logs_to_kinesis"
  role   = "${aws_iam_role.flowlog_subscription_role.id}"
  count  = "${var.enable_flowlog > 0 ? 1 : 0 }"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Action": [
        "kinesis:PutRecord*",
        "kinesis:DescribeStream",
        "kinesis:ListStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kinesis_stream.vpc_stream.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${aws_iam_role.flowlog_subscription_role.arn}"
    }
  ]
}
EOF
}
