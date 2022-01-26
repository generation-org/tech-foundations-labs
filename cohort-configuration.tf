# This configures new Tech Foundations Cohorts
# Add new cohorts to the locals.cohort map
locals {
  cohorts = {
    BIR99 : {
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDrrMuNdW6GceUKj6ke2IrugDaJrgEUGhdDAVLE9lC/+E/9nSqbGLsx/zZos2wHU2WTqPpihoq+1FOSrH9Iae+ep03C3PV6HvSudhFnBT8cQCxFkzJfzrGkTExQO27wToBX5FvnXJaGyj/IfHkEgILerLuLU/z0cVliuL5JacxIr8NMB5eA57GkX40GHkPWooaPs4UyIbVbpmwnjQhrF4ymPTyaa+imqn22MofD/8U5a2NBvPMFrzl6kGmabG9TO5xW8w+C/VvnOEG+wxYa6qpF4bWVWiqK/Hvuqe8IuqU1wjosUWbqEd2P6Q7hp79ry+FLZRgkLVa/q6974w7aUPRvmxyNxZFI9hjPhBa6xNnPsKeaF/LCjvwsfAhEKs/T7pR+VYy60F0QDDXekGMkhtnd+hQs1XTXznhSQg4W/fPmtvAEv9IwO2OW19TUarGoBsHtWwNKY8MzrvGIH2rO5UqT4/uY7d9IeN8b72HW/EFdR3xDUBafFrvMQCs3gDf9m3c= jamesbelchamber@pyrelaptop"
      learner_count         = 2
      single-vm-lab         = false
      cheeper-api           = false
    },
    us-cyb-nat1 : {
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDqv+ZjIhkV+ovMOFTAsiSpSameRVDfiJaH4k9gHYXUQIBIrI/TDybemn0nVuS3uEZkTbgqbE6g7WN6noWpoNsKhoU/cokCWCbDc7PbKCB0jqo6ykuEW7ymsz8jNatCq6YJ6BCMqfDlvhKWB32+q3xUMkI4Xd+iA8+/lva/scEOrGgAhln34MdZbVC4Y/D/Q9yOR7pBitwO9Yp/mEelQ0B1ko2HfgI9eiUtr3Yae1D9/yrSclB9P1SF85tYE3dIDhEe3kj/xGvlf3wddcr5ueZncpcAL5wsepwT7ukM9FA3yVtfklwVG9wp98IO0pxLglIMuWA6SXZcE2Anc+uu6tCtaSmPdhJXG4vK0oJrN0aIKLvl2MFZEFmMI8Qyhue43lfeSPYcSD9Vq8qWTlRhcYXqAoglVJgSnG0Np5Hx6QOFp5G1qUFoXefNq7JpA+a631TJF92RlxguqUtxWQlHLGTbBpy6lL3rumNF3Qx6M9D/HnAUptpdIlESyQHndqpN/5s= centos@ip-172-16-0-244.ec2.internal"
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
