#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

source "/luo/w/huwo/devops-shell/project.sh"

COMMAND=$1
DOCKER_REGISTRY_NAMESPACE=registry.cn-shenzhen.aliyuncs.com/callme

docker::build() {
    docker build -t ${DOCKER_REGISTRY_NAMESPACE}/${APP_IMAGE} .
}

docker::push() {
    docker push ${DOCKER_REGISTRY_NAMESPACE}/${APP_IMAGE}
}

docker::upgrade() {
    /luo/w/huwo/hw-helm-repo/main.sh ${APP_AUTHOR}-${APP_NAME} upgrade ${VERSION}
}

run() {
    local FUNC=$1

    if [ -n "$(type -t $FUNC)" ] && [ "$(type -t $FUNC)" = function ]; then
        echo $FUNC
        $FUNC
    fi
}

case $COMMAND in
    *)
        run docker::$COMMAND
        ;;
esac
