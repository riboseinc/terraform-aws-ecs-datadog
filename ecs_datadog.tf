resource "aws_ecs_task_definition" "datadog" {
  family        = "${var.env}-${var.identifier}-datadog-task"
  task_role_arn = aws_iam_role.ecs-datadog-role.arn

  container_definitions = <<EOF
[
  {
    "name": "${var.env}-${var.identifier}",
    "image": "public.ecr.aws/datadog/agent:latest",
    "cpu": 10,
    "memory": 512,
    "essential": true,
    "portMappings": [
        {
          "hostPort": 8126,
          "protocol": "tcp",
          "containerPort": 8126
        }
    ],
    "secrets": [
      "name": "DD_API_KEY",
      "valueFrom: "arn:aws:secretsmanager:us-east-1:447502150454:secret:production/datadog/api_key-cThpym"
    ]
    "environment": [
      {
        "name": "DD_LOGS_ENABLED",
        "value": "true"
      },{
        "name": "DD_APM_ENABLED",
        "value": "true"
      },{
        "name": "DD_APM_NON_LOCAL_TRAFFIC",
        "value": "true"
      },{
        "name": "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL",
        "value": "true"
      },{
        "name": "DD_APM_RECEIVER_SOCKET",
        "value": "/var/run/datadog/apm.socket"
      },{
        "name": "DD_AC_EXCLUDE",
        "value": "name:datadog-agent"
      }],
    "command": [
      "bash",
      "-c",
      "${var.datadog-extra-config}"
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
    },{
      "sourceVolume": "datadog",
      "containerPath": "/var/run/datadog/",
      "readOnly": false
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
    host_path = "/cgroup/"
  }

  volume {
    name      = "datadog"
    host_path = "/var/run/datadog/"
  }
}

resource "aws_ecs_service" "datadog" {
  name            = "${var.env}-${var.identifier}-datadog-ecs-service"
  cluster         = var.ecs-cluster-id
  task_definition = aws_ecs_task_definition.datadog.arn

  # This allows running once for every instance
  scheduling_strategy = "DAEMON"
}
