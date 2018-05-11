#!/usr/bin/env bash

logfile="/var/log/aws_userdata.log"

set -o errexit
set -o pipefail
set -o nounset


#### Docker
apt-get update

apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    jq

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get -y install docker-ce >> $logfile

#### AWS ECR
apt-get install -y python-pip >> $logfile
pip install -U pip >> $logfile
/usr/local/bin/pip install awscli >> $logfile
docker_login=$(aws ecr get-login --no-include-email --region $aws_region)
eval $docker_login >> $logfile

#### Gitlab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

cat > /etc/apt/preferences.d/pin-gitlab-runner.pref <<EOF
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF

apt-get install gitlab-runner="${gitlab_runner_version}" >> $logfile

cat > /etc/gitlab-runner/config.toml <<-EOF
concurrent = ${gitlab_runner_concurent_builds}
check_interval = 0
EOF

systemctl restart gitlab-runner.service >> $logfile

REGISTER_LOCKED=false REGISTER_RUN_UNTAGGED=false gitlab-runner register -n \
  --url ${gitlab_url} \
  --registration-token ${gitlab_runner_registration_token} \
  --executor docker \
  --description "Docker Runner" \
  --docker-image "ruby:2.4" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock\
  --tag-list ${gitlab_runner_tags}

REGISTER_LOCKED=false REGISTER_RUN_UNTAGGED=false gitlab-runner register -n \
  --url ${gitlab_url} \
  --registration-token ${gitlab_runner_registration_token} \
  --executor shell \
  --tag-list shell 
