# This configures new Tech Foundations Cohorts
# Add new cohorts to the locals.cohort map
locals {
  cohorts = {
    BIR99 : {
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCma37NKtcgEidIzoCbNI7L/zg556SnwEFyi1fbdbr1G5KUTBh9PvI5hRvdKdMv/t18p90YJnFclNfQR6/2wT63vVRgVO876TAcNJIbNPegO2firTjCwdAcHvpdCo891DcsEs3GaaXuvhwapuYrLgsOmXkOIrupeotyuZIsdcXYtzN3oKEz5WB9GpAuvzLNNTh0ZWJyFmz+Q/2RmtzScBd3ACVxGg/M48TSnGObnUlC3Z4Xm+uSFCzDgEfpCh/ElJVRxjj6u+7tq+MEvKox3BroPCF/DYEtsGJ6zX2rwy5xXJ5IO9tyIsZFCJXRg6UjHUgmXxiMFUFTI4qXKPHtbfQ3ctmurrs/5+yBwJhnkwsLNiP47oSSQ+CDjd8PpfTSIpI4VO8ZFR9mOkLmN2DnBiFYBHSmOEWK2OzC6aUaCGmgVdrZVStIWp9Elju6WoZlBkSGL2ulKRMEsV8KoxL18C2fSZceRTuhh/kutbcBZu9TkTI/XCL9NtqcZQsiDImp1n8= ted.logan@Ted-Logans-Macbook-Air.local"
      learner_count         = 1
      single-vm-lab         = false
      cheeper-api           = false
    },
  }
}

resource "aws_key_pair" "Instructor" {
  for_each   = local.cohorts
  key_name   = "${each.key}-instructor"
  public_key = each.value.instructor_public_key
  tags = {
    Course = "Tech Foundations"
    Cohort = each.key
    Name   = "${each.key} Instructor VM"
  }
}

resource "aws_instance" "InstructorVM" {
  for_each                    = aws_key_pair.Instructor
  ami                         = data.aws_ami.centos.id
  instance_type               = "t3a.micro"
  subnet_id                   = aws_subnet.global.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                    = each.value.key_name
  user_data                   = <<EOF
#!/bin/bash -xe
dnf install -y epel-release
dnf install -y ansible wget unzip
pip3 install -U pytest-testinfra
wget https://github.com/generation-org/tech-foundations-labs/archive/refs/heads/main.zip
unzip main.zip
cp -ar tech-foundations-labs-main/instructor_tools /home/centos/
chown -R centos:centos /home/centos/instructor_tools
mv /home/centos/instructor_tools/.ansible.cfg /home/centos/
mkdir -p /home/centos/.ssh
echo -e "Host *\n    StrictHostKeyChecking no" > /home/centos/.ssh/config
chown -R centos:centos /home/centos/.ssh
chmod 0600 /home/centos/.ssh/config
EOF

  tags = {
    Course = "Tech Foundations"
    Cohort = each.value.tags_all.Cohort
    Name   = "${each.value.tags_all.Cohort} Instructor VM"
  }
  lifecycle {
    ignore_changes = [ami]
  }
  credit_specification {
    cpu_credits = "standard"
  }
}

module "single-vm-lab" {
  for_each = {
    for key, value in local.cohorts : key => value
    if value.single-vm-lab == true
  }
  source            = "./modules/single-vm-lab"
  ami_id            = data.aws_ami.centos.id
  subnet_id         = aws_subnet.global.id
  security_group_id = aws_security_group.allow_all.id

  cohort_name           = each.key
  learner_count         = each.value.learner_count
  instructor_public_key = aws_key_pair.Instructor[each.key].key_name
}

module "cheeper-api" {
  for_each = {
    for key, value in local.cohorts : key => value
    if value.cheeper-api == true
  }
  source      = "./modules/cheeper-api"
  cohort_name = each.key
}
