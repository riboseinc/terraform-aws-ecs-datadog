resource "aws_ecs_task_definition" "datadog" {
  family        = "${var.env}-${var.identifier}-task"
  task_role_arn = "${aws_iam_role.ecs-datadog-role.arn}"

  container_definitions = <<EOF
[
  {
    "name": "${var.env}-${var.identifier}",
    "image": "datadog/agent:latest",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8126,
        "hostPort": 8126,
        "protocol": "tcp"
      }
    ],
    "environment": [
     {
      "name" : "DD_API_KEY",
      "value" : "${var.datadog-api-key}"
     },
     {
      "name" : "DD_SITE",
      "value" : "datadoghq.com"
     },
     {
      "name" : "DD_APM_ENABLED",
      "value" : "true"
     },
     {
      "name": "DD_LOGS_ENABLED",
      "value": "true"
     },
     {
      "name": "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL",
      "value": "true"
     },
     {
      "name": "SD_BACKEND",
      "value": "docker"
     },
     {
      "name" : "DD_APM_NON_LOCAL_TRAFFIC",
      "value" : "true"
     }
    ],
    "mountPoints": [{
      "sourceVolume": "docker-sock",
      "containerPath": "/var/run/docker.sock",
      "readOnly": true
    },{
      "sourceVolume": "proc",
      "containerPath": "/host/proc",
      "readOnly": true
    },{
      "sourceVolume": "cgroup",
      "containerPath": "/host/sys/fs/cgroup",
      "readOnly": true
    }]
  }
]
EOF

  volume {
    name      = "docker-sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "proc"
    host_path = "/proc/"
  }

  volume {
    name      = "cgroup"
    host_path = "/sys/fs/cgroup/"
  }
}

resource "aws_ecs_service" "datadog" {
  name            = "${var.env}-${var.identifier}-datadog-ecs-service"
  cluster         = "${var.ecs-cluster-id}"
  task_definition = "${aws_ecs_task_definition.datadog.arn}"

  # This allows running once for every instance
  scheduling_strategy = "DAEMON"
}
