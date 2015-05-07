#!/usr/bin/python

import argparse
import os
import os.path
import shutil
import sys
import uuid

CONTAINER = "xenserver/xenserver-build-env"
DOCKER_PATH = "/usr/bin/docker"
SRPMS_MOUNT_ROOT = "/tmp/docker-SRPMS"

def make_mount_dir():
    srpm_mount_dir = os.path.join(SRPMS_MOUNT_ROOT, str(uuid.uuid4()))
    try:
        os.makedirs(srpm_mount_dir)
    except OSError:
        pass
    return srpm_mount_dir

def copy_srpms(srpm_mount_dir, srpms):
    for srpm in srpms:
        srpm_name = os.path.basename(srpm)
        shutil.copyfile(srpm, os.path.join(srpm_mount_dir, srpm_name))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('xs_branch', help='XenServer branch name')
    parser.add_argument('srpms', nargs=argparse.REMAINDER,
                        help='SRPMs for which dependencies will be installed')
    args = parser.parse_args(sys.argv[1:])
    docker_args = [
        "docker", "run", "-e", "XS_BRANCH=%s" % args.xs_branch,
        "-i", "--rm=true", "-t"
        ]
    # Copy all the RPMs to the mount directory
    if args.srpms != []:
        srpm_mount_dir = make_mount_dir()
        copy_srpms(srpm_mount_dir, args.srpms)
        docker_args += ["-v", "%s:/mnt/docker-SRPMS" % srpm_mount_dir]
    # exec "docker run"
    docker_args += [CONTAINER]
    print "Launching docker with args %s" % docker_args
    os.execv(DOCKER_PATH, docker_args)

if __name__ == "__main__":
    main()
