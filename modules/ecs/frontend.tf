/*====
ECS task definitions
======*/

data "template_file" "frontend_task" {
  template = "${file("${path.module}/task_definitions/frontend.json")}"

  vars {
    image     = "${aws_ecr_repository.polyledger_app.repository_url}/client"
    log_group = "${aws_cloudwatch_log_group.polyledger.name}"
    npm_token = "${var.npm_token}"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.environment}_frontend"
  container_definitions    = "${data.template_file.frontend_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

/* Simply specify the family to find the latest ACTIVE revision in that family */
data "aws_ecs_task_definition" "frontend" {
  depends_on = [ "aws_ecs_task_definition.frontend" ]
  task_definition = "${aws_ecs_task_definition.frontend.family}"
}

/*====
ECS service
======*/

resource "aws_ecs_service" "frontend" {
  name            = "${var.environment}-frontend"
  task_definition = "${aws_ecs_task_definition.frontend.family}:${max("${aws_ecs_task_definition.frontend.revision}", "${data.aws_ecs_task_definition.frontend.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster =       "${aws_ecs_cluster.cluster.id}"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  network_configuration {
    security_groups = ["${var.security_groups_ids}", "${aws_security_group.ecs_service.id}"]
    subnets         = ["${var.subnets_ids}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "web"
    container_port   = "80"
  }

  depends_on = ["aws_alb_target_group.alb_target_group"]
}
