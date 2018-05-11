variable "project_name" {
  description = "this name will be used to name resources"
  default = "gitlab-docker-runner"
}

variable "aws_ec2_instance_type" {
  description = "profile name configured in ~/.aws/credentials file"
  default = "t2.medium"
}

variable "aws_ec2_subnet_tag_name" {
  description = "aws private subnet tag name"
  default = "private-us-west-2c"
}

variable "boot_disk_size" {
  description = "gitlab boot disk size in GB"
  default = 20
}

variable "boot_disk_type" {
  description = "gitlab boot disk type in GB"
  default = "standard"
}

variable "aws_ec2_keypair" {
  description = "aws ec2 keypair"
}

variable "gitlab_runner_version" {
  description = "runner version to install"
  default     = "10.6.0"
}

variable "gitlab_runner_concurent_builds" {
  description = "max concurent build on a runner"
  default     = 10
}

variable "gitlab_runner_tags" {
  description = "tag name for the runner"
  default     = "docker"
}

variable "gitlab_url" {
  description = "gitlab server url. ex: gitlab.example.com"
}

variable "gitlab_runner_registration_token" {
  description = "runner token. git it from gitlab ui runner page"
}

variable "gitlab_runner_count" {
  description = "Numbre of ec2 instances for runner"
  default = 1
}

variable "gitlab_runner_other_register_options" {
  description = "pass additional options while running register command(space separated). example:  --docker-privileged"
  default = ""
}

