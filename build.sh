#!/bin/sh
set -e
if [ -z $1 ]; then
    echo "Usage: $0 {version}"
    echo "... where {version} is either dev, latest (for latest stable release), or a 'x.y' version such as 7.5."
    exit
fi

sed -e "s/@XCP_NG_BRANCH@/$1/" files/xcp-ng.repo.in > files/tmp-xcp-ng.repo
docker build -t xcp-ng/xcp-ng-build-env-$1 .
rm files/tmp-xcp-ng.repo -f
