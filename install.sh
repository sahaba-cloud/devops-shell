#!/usr/bin/env bash
mkdir -p /opt/sahaba
git clone https://github.com/sahaba-cloud/devops-shell.git /opt/sahaba/devops-shell
ln -s /opt/sahaba/devops-shell/main.sh /usr/local/bin/devops-shell
