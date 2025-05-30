resource "aws_launch_template" "ecs_instance" {
  name_prefix   = "ecs-instance-${var.env}"
  image_id      = data.aws_ami.latest_ecs_ami.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.key_pair.key_name

  network_interfaces {
    associate_public_ip_address = true
    # security_groups             = [aws_security_group.alb_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.app_cluster_name}" >> /etc/ecs/ecs.config
EOF
  )
}

resource "aws_autoscaling_group" "ecs_instances" {
  name                = "autoscaling-group-${var.app_cluster_name}"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.ecs_instance.id
    version = "$Latest"
  }

  protect_from_scale_in = true
  target_group_arns     = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.app_cluster_name

}

resource "aws_ecs_capacity_provider" "elastic_cp_app" {
  name = "elastic-cp-app-${var.env}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_instances.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
      instance_warmup_period    = 300
    }
  }

  depends_on = [
    aws_ecs_cluster.app_cluster,
    aws_ecs_capacity_provider.elastic_cp_app
  ]
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp_config" {
  cluster_name = aws_ecs_cluster.app_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.elastic_cp_app.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.elastic_cp_app.name
    weight            = 1
    base              = 1
  }
}


resource "aws_ecs_task_definition" "app_task" {
  family                   = var.app_task_family
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.app_container_name}",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 1024,
      "cpu": 512,
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval": 30,
        "timeout": 10,
        "retries": 3,
        "startPeriod": 10
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = 3072
  cpu                      = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "app_service" {
  name            = var.app_service_name
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.app_container_name
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-2a, us-east-2b, us-east-2c]"
  }
}

