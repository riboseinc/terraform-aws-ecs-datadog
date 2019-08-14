resource "aws_iam_role" "ecs-datadog-role" {
  name = "${var.env}-${var.identifier}-jenkins-ecs-datadog-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-task-role-assume.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-datadog" {
  role = "${aws_iam_role.ecs-datadog-role.name}"
  policy_arn = "${aws_iam_policy.ecs-datadog-role-policy.arn}"
}

resource "aws_iam_policy" "ecs-datadog-role-policy" {
  name = "${var.env}-${var.identifier}-datadog-agent-ecs-iam-role-policy"
  policy = "${data.aws_iam_policy_document.ecs-datadog-role.json}"
}

data "aws_iam_policy_document" "ecs-datadog-role" {

  statement {
    sid = "AllowDatadogToReadECSMetrics"
    effect = "Allow"
    actions = [
      "ecs:RegisterContainerInstance",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Submit*",
      "ecs:Poll",
      "ecs:StartTask",
      "ecs:StartTelemetrySession"
    ]
    resources = [ "*" ]
  }

}

data "aws_iam_policy_document" "ecs-task-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

