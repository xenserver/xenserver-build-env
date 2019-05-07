#!/bin/bash
set -e
if [ -z $1 ]; then
    echo "Usage: $0 {version}"
    echo "... where {version} is a 'x.y' version such as 8.0."
    exit
fi

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

docker build -t xcp-ng/xcp-ng-build-env:$1 -f Dockerfile-$MAJOR.x .

rm files/tmp-xcp-ng.repo -f
rm files/tmp-CentOS-Vault.repo -f
