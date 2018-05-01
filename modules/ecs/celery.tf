/*====
ECS task definitions
======*/

resource "template_file" "celery_task" {
  template = "${file("${path.module}/task_definitions/celery.json")}"

  vars {
    image = "${aws_ecr_repository.polyledger_app.repository_url}"
  }
}

resource "aws_ecs_task_definition" "celery-task" {
  family                   = "${var.environment}_celery"
  container_definitions    = "${template_file.celery_task.rendered}"
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

resource "aws_ecs_service" "celery-service" {
  name            = "${var.environment}-celery"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.celery-task.arn}"
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
