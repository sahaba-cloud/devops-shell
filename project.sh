#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

# PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)
PROJECT_ROOT=$(pwd -P)
CONFIG_FILE=${PROJECT_ROOT}/.sahaba.yml

##########################
# Get config from .git
##########################
GIT_COMMIT=`git rev-parse HEAD | cut -c 1-7`
GIT_TAG=$(git describe --exact-match --abbrev=0 --tags ${GIT_COMMIT} 2> /dev/null || true)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

##########################
# COMPUTE VERSION
##########################
VERSION=$(shyaml get-value version 0.0.1 < $CONFIG_FILE)
[[ -z $(git status -s) ]] || VERSION=${VERSION}-dev.
VERSION=${VERSION}-${GIT_COMMIT}


BUILD_DATE=$(date '+%G-%m-%d')
BUILD_TIME=$(date '+%H:%M:%S')

INFER_LANGUAGE=golang
APP_LANGUAGE=$INFER_LANGUAGE
# /go/src/github.com/ hg2c /swain-go
_HEAD=${PROJECT_ROOT%/*}
INFER_AUTHOR=${_HEAD##*/}
# /go/src/github.com/hg2c/ swain-go
INFER_NAME=${PROJECT_ROOT##*/}

APP_NAME=${APP_NAME:-$INFER_NAME}
APP_AUTHOR=${APP_AUTHOR:-$INFER_AUTHOR}
APP_IMAGE=${APP_AUTHOR}-${APP_NAME}:${VERSION}

if [ -s "./scripts/${APP_LANGUAGE}.sh" ]; then source ./scripts/${APP_LANGUAGE}.sh; fi


# TODO dry run
run() {
    echo RUN: $@ && eval $@;
    echo DRYRUN: $@;
}

show() {
    local N=$1
    eval "echo $N: \$$N"
}

show PROJECT_ROOT
show APP_NAME
show APP_AUTHOR
show APP_LANGUAGE
show VERSION
show APP_IMAGE
show GIT_TAG
show GIT_BRANCH

echo ------------

build() {
    # run ${APP_LANGUAGE}::build $APP_NAME $APP_PACKAGE
    for MODULE in ${HGC_MODULES}; do
        run ${APP_LANGUAGE}::build $MODULE $APP_PACKAGE/$MODULE
    done
}

docker::build() {
    IMAGE_NAME=$1
    IMAGE_VERSION=$2
    IMAGE_FILE=$3

    run docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} -f ${IMAGE_FILE} .

    run docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${IMAGE_NAME}:latest
}


hgc::docker::build() {
    for MODULE in ${HGC_MODULES}; do
        run docker::build ${APP_AUTHOR}/${APP_NAME}-${MODULE} ${GIT_COMMIT} ${MODULE}/Dockerfile
    done
}
