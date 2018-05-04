/*====
ECS task definitions
======*/

resource "template_file" "celery_beat_task" {
  template = "${file("${path.module}/task_definitions/celery_beat.json")}"

  vars {
    image     = "${aws_ecr_repository.polyledger_app.repository_url}"
    log_group = "${aws_cloudwatch_log_group.polyledger.name}"
  }
}

resource "aws_ecs_task_definition" "celery_beat_task" {
  family                   = "${var.environment}_celery_beat"
  container_definitions    = "${template_file.celery_beat_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

/*====
ECS service
======*/

resource "aws_ecs_service" "celery_beat_service" {
  name            = "${var.environment}-celery-beat"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.celery_beat_task.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  network_configuration {
    security_groups = ["${var.security_groups_ids}", "${aws_security_group.ecs_service.id}"]
    subnets         = ["${var.subnets_ids}"]
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
