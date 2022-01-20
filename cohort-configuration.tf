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
      instructor_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGKkaL0U82Dj0DGS+jAMcFTiOvueC40C5zkOKOPxMSYrm9o4RLP8upKXwqyllW30xxIS6hfIBT7tyG6fBstoiptBg6/9pptbS0G4IdNaTEjmqcJi0f3Z8tlvM6676LG/+VDeTnPoGICc9PNKT9ZEujs/GItTvdrHU8QiZY4qAFdA8ZwzdxOQM/HHRjTFzgtnUTWejVSm7t15rLIhsxAzapZTKht15PYQPpiV2LPyzQPSsAwAK4oNLjwJdHuwlAz0Vxu2J15ywg8VoipdU2aY3s/QNGnoBRCS4Q9oICmMjB8SEvuHtNQ8feX8utAvQuZyOs6hslx6hXB6JDuYUzFdmQnS47hxeQDTa6ymilb7/4QdOnD5nbvA7SHUo2czvbrljGy10NjhpZq0zlbTsPwj5r4iW3Iq9Du073zfZeTUvSV4hKdLcyF4GAN/Co35i0vYa7pFCus7xBbOyJKA686A5IY78GJ6nJZCX0EcTCmn+NVO4EGgMLa2eZfLQEUFCvNsU= giovannipro@MBP-3.home"
      learner_count         = 117
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
