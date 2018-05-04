/*====
ECS task definitions
======*/

/* the task definition for the web service */
data "template_file" "web_task" {
  template = "${file("${path.module}/task_definitions/web.json")}"

  vars {
    image                    = "${aws_ecr_repository.polyledger_app.repository_url}"
    secret_key_base          = "${var.secret_key_base}"
    database_url             = "postgresql://${var.database_username}:${var.database_password}@${var.database_endpoint}:5432/${var.database_name}?encoding=utf8&pool=40"
    redis_url                = "redis://${var.redis_endpoint}:6379/1"
    log_group                = "${aws_cloudwatch_log_group.polyledger.name}"
    email_host_password      = "${var.email_host_password}"
    npm_token                = "${var.npm_token}"
    bitbutter_api_key        = "${var.bitbutter_api_key}"
    bitbutter_api_secret     = "${var.bitbutter_api_secret}"
    bitbutter_partnership_id = "${var.bitbutter_partnership_id}"
    bitbutter_partner_id     = "${var.bitbutter_partner_id}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.environment}_web"
  container_definitions    = "${data.template_file.web_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

/* Simply specify the family to find the latest ACTIVE revision in that family */
data "aws_ecs_task_definition" "web" {
  depends_on = [ "aws_ecs_task_definition.web" ]
  task_definition = "${aws_ecs_task_definition.web.family}"
}

/*====
ECS service
======*/

resource "aws_ecs_service" "web" {
  name            = "${var.environment}-web"
  task_definition = "${aws_ecs_task_definition.web.family}:${max("${aws_ecs_task_definition.web.revision}", "${data.aws_ecs_task_definition.web.revision}")}"
  desired_count   = 2
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
