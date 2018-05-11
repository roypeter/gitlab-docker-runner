data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"
  vars {
    gitlab_url = "${var.gitlab_url}"
    gitlab_runner_registration_token = "${var.gitlab_runner_registration_token}"
    gitlab_runner_version = "${var.gitlab_runner_version}"
    gitlab_runner_tags = "${var.gitlab_runner_tags}"
    gitlab_runner_concurent_builds = "${var.gitlab_runner_concurent_builds}"
    gitlab_runner_other_register_options = "${var.gitlab_runner_other_register_options}"
  }
}

data "aws_subnet" "ec2" {
  filter {
    name   = "tag:Name"
    values = ["*${var.aws_ec2_subnet_tag_name}*"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2"
  description = "${var.project_name}-ec2"
  vpc_id      = "${data.aws_subnet.ec2.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","192.168.0.0/16", "172.16.0.0/12"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  count = "${var.gitlab_runner_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.aws_ec2_instance_type}"
  subnet_id     = "${data.aws_subnet.ec2.id}"
  user_data     = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.ec2.id}"]
  key_name = "${var.aws_ec2_keypair}"

  root_block_device = {
    volume_type = "${var.boot_disk_type}"
    volume_size = "${var.boot_disk_size}"
    delete_on_termination = true
  }

  tags {
    Name = "${var.project_name}-${count.index + 1}"
  }
}
