#--- compute/main.tf
resource "aws_key_pair" "tfmh_keypair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "aws_ami" "tfmh_server_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}
data "template_file" "tfmh_userdata" {
  count = length(var.subpub_ids)

  template = file("${path.module}/userdata.tpl")
  vars = {
    subnets = element(var.subpub_ids, count.index)
  }
}
resource "aws_instance" "tfmh_server" {
  count = length(var.subpub_ids)

  instance_type           = var.instance_type
  ami                     = data.aws_ami.tfmh_server_ami.id
  key_name                = aws_key_pair.tfmh_keypair.id
  subnet_id               = element(var.subpub_ids, count.index)
  vpc_security_group_ids  = [var.sg_id]
  user_data               = data.template_file.tfmh_userdata.*.rendered[count.index]
  tags = { 
    Name = format("%s_server_%d", var.project_name, count.index)
    project_name = var.project_name
  }
}


#--- ALB 
resource "aws_security_group" "tfmh_alb" {
  name          = "tfmh_alb"
  vpc_id        = var.vpc_id
  # Allow all inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "tfmh_lb" {
  name               = "tfmh-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tfmh_alb.id]
  subnets            = var.subpub_ids
  tags = { 
    Name = format("%s_tfmh_lb", var.project_name)
    project_name = var.project_name
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tfmh_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfmh_lbtrggrp.arn
  }
}

resource "aws_lb_target_group" "tfmh_lbtrggrp" {
  name     = "tfmh-lbtrggrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }  
}

resource "aws_lb_target_group_attachment" "tfmh_lbtrggrpatt" {
  count            = length(var.subpub_ids)

  target_group_arn = aws_lb_target_group.tfmh_lbtrggrp.arn
  target_id        = aws_instance.tfmh_server[count.index].id
  port             = 80
}
