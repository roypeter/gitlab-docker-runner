#!/usr/bin/env bash

logfile="/var/log/aws_userdata.log"

set -o errexit
set -o pipefail
set -o nounset

echo 'Install Docker'

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

echo 'Install Gitlab Runner'
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

DOCKER_IMAGE="ruby:2.4" REGISTER_LOCKED=false gitlab-runner register \
  --non-interactive \
  --url ${gitlab_url} \
  --executor docker \
  --registration-token ${gitlab_runner_registration_token} \
  --tag-list ${gitlab_runner_tags} \
  --run-untagged false >> $logfile

