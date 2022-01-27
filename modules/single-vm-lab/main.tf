resource "aws_instance" "LearnerVM" {
  count                                = var.learner_count
  ami                                  = var.ami_id
  instance_type                        = "t3a.micro"
  subnet_id                            = var.subnet_id
  vpc_security_group_ids               = [var.security_group_id]
  associate_public_ip_address          = true
  key_name                             = var.instructor_public_key
  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Course = "Tech Foundations"
    Cohort = var.cohort_name
    Name   = "${var.cohort_name} Learner VM ${count.index}"
  }
  lifecycle {
    ignore_changes = [ami]
  }
  credit_specification {
    cpu_credits = "standard"
  }
}

resource "random_password" "learner_passwords" {
  count   = var.learner_count
  length  = 12
  special = false
  number  = true
  upper   = true
  lower   = true
}

resource "local_file" "inventory" {
  content  = templatefile("${path.module}/inventory.tfpl", { users = zipmap(aws_instance.LearnerVM[*].public_dns, random_password.learner_passwords[*].result) })
  filename = "${path.root}/${var.cohort_name}-inventory"
}
