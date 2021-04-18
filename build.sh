#!/bin/bash
set -e
if [ -z $1 ]; then
    echo "Usage: $0 {version}"
    echo "... where {version} is a 'x.y' version such as 8.0."
    exit
fi

CUSTOM_ARGS=()

MAJOR=${1:0:1}

if [ $MAJOR -eq 7 ]; then
    REPO_FILE=files/xcp-ng.repo.7.x.in
    CENTOS_VERSION=7.2.1511
else
    REPO_FILE=files/xcp-ng.repo.8.x.in
    CENTOS_VERSION=7.5.1804
fi

sed -e "s/@XCP_NG_BRANCH@/$1/g" "$REPO_FILE" > files/tmp-xcp-ng.repo
sed -e "s/@CENTOS_VERSION@/$CENTOS_VERSION/g" files/CentOS-Vault.repo.in > files/tmp-CentOS-Vault.repo

# Support using docker on arm64, building
# for amd64 (e.g. Apple Silicon)
if [ "$(uname -m)" == "arm64" ]; then
    CUSTOM_ARGS+=( "--platform" "linux/amd64" )
fi

# Support for seamless use of current host user
# and Docker user "builder" inside the image
CUSTOM_ARGS+=( "--build-arg" "CUSTOM_BUILDER_UID=$(id -u)" )
CUSTOM_ARGS+=( "--build-arg" "CUSTOM_BUILDER_GID=$(id -g)" )

docker build \
    $(echo "${CUSTOM_ARGS[@]}") \
    -t xcp-ng/xcp-ng-build-env:$1 \
    -f Dockerfile-$MAJOR.x .

rm -f files/tmp-xcp-ng.repo
rm -f files/tmp-CentOS-Vault.repo
