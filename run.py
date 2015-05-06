#!/usr/bin/python

import os
import os.path
import shutil
import sys
import uuid

CONTAINER = "xenserver/xenserver-build-env"
DOCKER_PATH = "/usr/bin/docker"
SRPMS_MOUNT_ROOT = "/tmp/docker-SRPMS"

def usage():
    print "./run <XS BRANCH> <SRPM PATH 1> [<SRPM PATH 2> ...]"
    sys.exit(1)

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
    if len(sys.argv) < 3:
        usage()
    else:
        # Copy all the RPMs to the mount directory
        xs_branch = sys.argv[1]
        srpms = sys.argv[2:]
        srpm_mount_dir = make_mount_dir()
        copy_srpms(srpm_mount_dir, srpms)
        # exec "docker run"
        os.execv(DOCKER_PATH, [
            "docker", "run", "-e", "XS_BRANCH=%s" % xs_branch,
            "-i", "--rm=true", "-t",
            "-v", "%s:/mnt/docker-SRPMS" % srpm_mount_dir, CONTAINER
            ])

if __name__ == "__main__":
    main()
