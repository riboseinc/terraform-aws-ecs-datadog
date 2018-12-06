output "ecs-task-definition-arn" {
  value = "${aws_ecs_task_definition.datadog.arn}"
}

output "ecs-task-definition-family" {
  value = "${aws_ecs_task_definition.datadog.family}"
}
