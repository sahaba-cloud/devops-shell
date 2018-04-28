#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

MODULE=project

BUILD_DATE=$(date '+%G-%m-%d')
BUILD_TIME=$(date '+%H:%M:%S')

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)
APP_ROOT=$(pwd -P)
APP_CONFIG=${APP_ROOT}/.sahaba.yml

##########################
# CONFIGURATION PRIORITY
# 1. APP_ROOT/.sahaba.yml
# 2. ENV
# 3. SCRIPT_ROOT/config.sh
##########################

source ${SCRIPT_ROOT}/config.sh

if [ -s "${APP_CONFIG}" ]; then
    APP_VERSION=$(shyaml get-value version ${APP_VERSION} < $APP_CONFIG)
    APP_LANGUAGE=$(shyaml get-value language ${APP_LANGUAGE} < $APP_CONFIG)
fi

# /go/src/github.com/ hg2c /swain-go
_HEAD=${APP_ROOT%/*}
INFER_AUTHOR=${_HEAD##*/}
# /go/src/github.com/hg2c/ swain-go
INFER_NAME=${APP_ROOT##*/}

APP_NAME=${APP_NAME:-$INFER_NAME}
APP_AUTHOR=${APP_AUTHOR:-$INFER_AUTHOR}

##########################
# GET FROM .git
##########################
GIT_COMMIT=`git rev-parse HEAD | cut -c 1-7`
GIT_TAG=$(git describe --exact-match --abbrev=0 --tags ${GIT_COMMIT} 2> /dev/null || true)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

##########################
# COMPUTE VERSION
##########################
[[ -z $(git status -s) ]] || APP_VERSION=${APP_VERSION}-dev
APP_VERSION=${APP_VERSION}-${GIT_COMMIT}

APP_IMAGE=${APP_AUTHOR}-${APP_NAME}:${APP_VERSION}

##########################
# LANGUAGE SPECIAL CONFIG
##########################
if [ -s "${SCRIPT_ROOT}/${APP_LANGUAGE}.sh" ]; then source ${SCRIPT_ROOT}/${APP_LANGUAGE}.sh; fi

run() {
    if [ "${DRYRUN-}" == "true" ]; then
        echo DRYRUN: $@;
    else
        echo RUN: $@ && eval $@;
    fi
}

show() {
    local N=$1
    eval "echo $N: \$$N"
}

show SCRIPT_ROOT
show APP_ROOT
show APP_NAME
show APP_AUTHOR
show APP_LANGUAGE
show APP_VERSION
show APP_IMAGE
show GIT_TAG
show GIT_BRANCH

echo ------------

for COMMAND in "$@"
do
    $COMMAND
done
