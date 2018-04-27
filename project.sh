#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

##########################
# CONFIGURATION PRIORITY
# 1. ENV
# 2. APP_ROOT/.sahaba.yml
# 3. SCRIPT_ROOT/config.sh
##########################

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)
source ${SCRIPT_ROOT}/config.sh

BUILD_DATE=$(date '+%G-%m-%d')
BUILD_TIME=$(date '+%H:%M:%S')

APP_ROOT=$(pwd -P)
APP_CONFIG=${APP_ROOT}/.sahaba.yml

if [ -s "${APP_CONFIG}" ]; then
    APP_VERSION=$(shyaml get-value version 0.0.1 < $APP_CONFIG)
else
    APP_VERSION=0.0.1
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
[[ -z $(git status -s) ]] || APP_VERSION=${APP_VERSION}-dev.
APP_VERSION=${APP_VERSION}-${GIT_COMMIT}
APP_IMAGE=${APP_AUTHOR}-${APP_NAME}:${APP_VERSION}

##########################
# LANGUAGE SPECIAL CONFIG
##########################
INFER_LANGUAGE=golang
APP_LANGUAGE=$INFER_LANGUAGE
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
