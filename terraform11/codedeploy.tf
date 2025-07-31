resource "aws_codedeploy_app" "strapi" {
  name             = "codedeploy-app-ruti-t11"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "strapi" {
  app_name              = aws_codedeploy_app.strapi.name
  deployment_group_name = "strapi-codedeploy-dg"
  service_role_arn      = var.codedeploy_role_arn

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.strapi.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  depends_on = [aws_ecs_service.strapi]
}
