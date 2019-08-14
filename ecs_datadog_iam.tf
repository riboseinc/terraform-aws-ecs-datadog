variable "datadog_aws_integration_external_id" {
  default = "0e21499d3743404bbd8ab31b05bce792"
  description = ""
}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        "${var.datadog_aws_integration_external_id}"
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = [
      "ecs:Describe*",
      "ecs:List*"
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationPolicy"
  policy = "${data.aws_iam_policy_document.datadog_aws_integration.json}"
}

resource "aws_iam_role" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationRole"
  description = "Role for Datadog AWS Integration"
  assume_role_policy = "${data.aws_iam_policy_document.datadog_aws_integration_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role = "${aws_iam_role.datadog_aws_integration.name}"
  policy_arn = "${aws_iam_policy.datadog_aws_integration.arn}"
}