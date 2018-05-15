provider "aws" {
  region  = "us-west-2"
}

module "gitlab" {
  source = "../../"
  gitlab_url = "https://gitlab.example.com"
  gitlab_runner_registration_token = "git this id from gitla UI admin/runner section"
  aws_ec2_keypair = "ec2 key pair name"
  gcloud_service_account = "base64 encoded gcloud service account json file"
}
