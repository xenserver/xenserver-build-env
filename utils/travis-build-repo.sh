#!/bin/sh

# This script is intended to called from inside a git repo by travis.
# It will download travis-build-repo-internal.sh and run.py, launch a
# xenserver-build-env container with the git repo mounted, and will finally
# run the script travis-build-repo-internal.sh inside the container.
#
# travis-build-repo.sh makes use of the following environment variables:
# $BUILDENV_USER (optional - default 'xenserver')
# - The github user from which to pull the required scripts.
# $BUILDENV_BRANCH (optional - default 'master')
# - The github branch from which to pull the required scripts.
# $REPO_PACKAGE_NAME (required)
# - The package for which dependencies will be installed in the container.
# $REPO_CONFIGURE_CMD (optional - default './configure')
# - The configure command to run in the repo.
# $REPO_BUILD_CMD (optional - default 'make')
# - The build command to run in the repo.
# $REPO_TEST_CMD (optional - default 'make test')
# - The test command to run in the repo.

set -eux

BUILDENV_USER=${BUILDENV_USER:-xenserver}
BUILDENV_BRANCH=${BUILDENV_BRANCH:-master}

wget https://raw.githubusercontent.com/${BUILDENV_USER}/xenserver-build-env/${BUILDENV_BRANCH}/run.py
wget https://raw.githubusercontent.com/${BUILDENV_USER}/xenserver-build-env/${BUILDENV_BRANCH}/utils/travis-build-repo-internal.sh

REPO=`basename $PWD`
REPO_PATH=/repos/$REPO

REPO_CONFIGURE_CMD=${REPO_CONFIGURE_CMD:-./configure}
REPO_BUILD_CMD=${REPO_BUILD_CMD:-make}
REPO_TEST_CMD=${REPO_TEST_CMD:-make test}

python run.py -p $REPO_PACKAGE_NAME --rm \
    -e "REPO_CONFIGURE_CMD=$REPO_CONFIGURE_CMD" \
    -e "REPO_BUILD_CMD=$REPO_BUILD_CMD" \
    -e "REPO_TEST_CMD=$REPO_TEST_CMD" \
    -v $PWD:$REPO_PATH \
    sh $REPO_PATH/travis-build-repo-internal.sh $REPO_PATH
