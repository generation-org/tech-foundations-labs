# This configures new Tech Foundations Cohorts
# Add new cohorts to the locals.cohort map
locals {
  cohorts = {
    BIR99 : {
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDua0etou9YbuRgXacCzoYpihp8ibPORYOVToBHMgPUGnGv09hNI4U5J7G5mYtg2k4piqsTwoWhCMCZSN+pxfe/MJywLRbgBPK1QUXynougmFlKFBJpRfwX0d0eKVTzUK2fltrIh89tor7bfaM2wFXim+k8HArJVRlp2aase8swb4t5rzwC5nmYt+KS1IaiU6zT8rJwGIooFKQnovw7WFaGIEkMHOetxhP+b8YwyNh+LVqvXvDuEWgIb+hnUskBWOlxwwh6fqRlI7+Ghaly9xo1HCjFqq1j9CnBBi29NBBm9hQti1+FHIBqy2wJCh/KoHgDjvbcfM0/wE+ebsXISmVuh2sJqc+LRg1XwbVYbrFH+mBk6RMaIJiphRS6nTtYY8lM1dbR3yQArgfe3D4VvgkAGbqxaHYR2rbXH7C7lk7Han3q7iSXiGKxhAIvnr5j8klpq3iVhRH4wwya1QaPBjXMIK/4NfeouVuG0T6p2mYcnZ3RBoQwxtFXW2Lyi2GeHJRznT9axqQL0eUbSA6YEe6oBO1uhLqt+orFTNkcz4aGqyybEXw9ncV/AZs630Cl/UfHjOuCOmxFx84wqNk8yIbwE4fC6aDJzSMxur70leOHnFnGgjLfnZXZBnc0G4ZD1K6aOVE2nQ+08emcuiN+Cblt98edEuiUVobTIZ/TC7iO+w=="
      learner_count         = 2
      single-vm-lab         = false
      cheeper-api           = false
    },
    us-cyb-nat1 : {
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrYYCNe9zt55AaUUDdastdW6n2KHFQRtvG+R9NL/QFRP6qnMSkYRJh0llMcwxk5NGt4uvh4i5QPiLk34YR+x0Rb3nJjQB/1wwXsuXP/u7+g9A80/xfdzi7fJ7dxNKBV1AfmoxFGLEt8gj600Ar3szVNnaMl+r5euaZ4CGAXm1eFzErN1FQj5n0VinFPwYpt77Z/1HU15IblojKrWWsgkjzZuWfiXeKBlt9RvDdvmLft6UtR70VLCHCnglso2ouFs+99o4u+VVSY7zj2hlOiP6VA3cX8VgXt/x5kG+9W0E14hOGWvrsAgzVU5w8RL4ZUFUbFO186JqR601P5auM6BF1Y/iTndsLakMRatcWjm0uYLQLO4yFzQjW3BtqO/Gn+/hczZLDLJwMeG1VnxdDsJ4XN4goAIqjc96D9m4L1Tx7wSnQyDrfQPmTwmlqz16LQSAPAR4w8BEtCjV9XoyGE8YPtaTg5Z9Bxg+6sPRz+LRtIT9v8xTKUGJlpNQPNMd4pnk= centos@ip-172-16-0-205.ec2.internal"
      learner_count         = 114
      single-vm-lab         = false
      cheeper-api           = true
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
dnf update -y
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
