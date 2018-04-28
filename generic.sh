#!/usr/bin/env bash
docker:build() {
    run docker build -t ${DOCKER_REGISTRY_NAMESPACE}/${APP_IMAGE} .
}

docker:push() {
    run docker push ${DOCKER_REGISTRY_NAMESPACE}/${APP_IMAGE}
}

helm:upgrade() {
    run /luo/w/huwo/hw-helm-repo/main.sh ${APP_AUTHOR}-${APP_NAME} upgrade ${APP_VERSION}
}
