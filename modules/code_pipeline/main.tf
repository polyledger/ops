resource "aws_s3_bucket" "client_assets" {
  bucket        = "polyledger-codepipeline-client-assets"
  acl           = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "source_artefacts" {
  bucket        = "polyledger-codepipeline-source-artefacts"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = "${file("${path.module}/policies/codepipeline_role.json")}"
}

/* policies */
data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/policies/codepipeline_policy.json")}"

  vars {
    aws_s3_bucket_arn        = "${aws_s3_bucket.source_artefacts.arn}"
    aws_s3_bucket_assets_arn = "${aws_s3_bucket.client_assets.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

/*
/* CodeBuild
*/
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = "${file("${path.module}/policies/codebuild_role.json")}"
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/policies/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn        = "${aws_s3_bucket.source_artefacts.arn}"
    aws_s3_bucket_assets_arn = "${aws_s3_bucket.client_assets.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  role        = "${aws_iam_role.codebuild_role.id}"
  policy      = "${data.template_file.codebuild_policy.rendered}"
}

data "template_file" "buildspec_client" {
  template = "${file("${path.module}/buildspec_client.yml")}"

  vars {
    assets_bucket_name = "${aws_s3_bucket.client_assets.bucket}"
    # We need it to run `npm build` in the builspec.yml
    npm_token          = "${var.npm_token}"
    repository_url     = "${var.frontend_repository_url}"
    region             = "${var.region}"
    # Not needed now but needed to run the migrate task
    cluster_name       = "${var.ecs_cluster_name}"
    subnet_id          = "${var.run_task_subnet_id}"
    security_group_ids = "${join(",", var.run_task_security_group_ids)}"
  }
}

data "template_file" "buildspec_server" {
  template = "${file("${path.module}/buildspec_server.yml")}"

  vars {
    repository_url     = "${var.server_repository_url}"
    region             = "${var.region}"
  }
}

resource "aws_codebuild_project" "polyledger_build_client" {
  name          = "polyledger-codebuild-client"
  # We need a bigger timeout here, running npm install takes time
  build_timeout = "20"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/nodejs:8.11.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec_client.rendered}"
  }
}

resource "aws_codebuild_project" "polyledger_build_server" {
  name          = "polyledger-codebuild-server"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/ubuntu-base:14.04"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec_server.rendered}"
  }
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "polyledger-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source_artefacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "polyledger"
        Repo       = "polyledger"
        Branch     = "mpigassou/michel/ecs"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build-Client"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["client-imagedefinitions"]

      configuration {
        ProjectName = "polyledger-codebuild-client"
      }
    }

    action {
      name             = "Build-Server"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["server-imagedefinitions"]

      configuration {
        ProjectName = "polyledger-codebuild-server"
      }
    }
  }

  stage {
    name = "Deploy"

    # action {
    #   name            = "Deploy-Client"
    #   category        = "Deploy"
    #   owner           = "AWS"
    #   provider        = "ECS"
    #   input_artifacts = ["client-imagedefinitions"]
    #   version         = "1"
    #
    #   configuration {
    #     ClusterName = "${var.ecs_cluster_name}"
    #     ServiceName = "${var.ecs_service_name}"
    #     FileName    = "client-imagedefinitions.json"
    #   }
    # }

    action {
      name            = "Deploy-Server"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["server-imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${var.ecs_cluster_name}"
        ServiceName = "${var.ecs_service_name}"
        FileName    = "server-imagedefinitions.json"
      }
    }
  }
}
