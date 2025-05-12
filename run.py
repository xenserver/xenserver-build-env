#!/usr/bin/python

"""
Thin wrapper around "docker run" which simplifies the creation of a build
environment for XenServer packages.
"""

import argparse
import os
import os.path
import subprocess
import shutil
import sys
import uuid

CONTAINER = "xenserver/xenserver-build-env"
SRPMS_MOUNT_ROOT = "/tmp/docker-SRPMS"


def make_mount_dir():
    """
    Make a randomly-named directory under SRPMS_MOUNT_ROOT.
    """
    srpm_mount_dir = os.path.join(SRPMS_MOUNT_ROOT, str(uuid.uuid4()))
    try:
        os.makedirs(srpm_mount_dir)
    except OSError:
        pass
    return srpm_mount_dir


def copy_srpms(srpm_mount_dir, srpms):
    """
    Copy each SRPM into the mount directory.
    """
    for srpm in srpms:
        srpm_name = os.path.basename(srpm)
        shutil.copyfile(srpm, os.path.join(srpm_mount_dir, srpm_name))


def main():
    """
    Main entry point.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--branch',
                        help='XenServer branch name. Leave unset unless you '
                             'plan to build from the internal Citrix repos')
    parser.add_argument('-p', '--package', action='append',
                        help='Packages for which dependencies will '
                        'be installed')
    parser.add_argument('-s', '--srpm', action='append',
                        help='SRPMs for which dependencies will be installed')
    parser.add_argument('-d', '--dir', action='append',
                        help='Local dir to mount in the '
                        'image. Will be mounted at /external/<dirname>')
    parser.add_argument('-e', '--env', action='append',
                        help='Environment variables passed directly to '
                             'docker -e')
    parser.add_argument('-v', '--volume', action='append',
                        help='Volume mounts passed directly to docker -v')
    parser.add_argument('--rm', action='store_true',
                        help='Destroy the container on exit')
    parser.add_argument('--syslog', action='store_true',
                        help='Enable syslog to host by mounting in /dev/log')
    parser.add_argument('--name', help='Assign a name to the container')
    parser.add_argument('command', nargs=argparse.REMAINDER,
                        help='Command to run inside the prepared container')

    args = parser.parse_args(sys.argv[1:])
    docker_args = ["docker", "run", "-i", "-t", "-u", "builder"]
    if args.rm:
        docker_args += ["--rm=true"]
    if args.branch:
        docker_args += ["-e", "XS_BRANCH=%s" % args.branch]
    if args.command != []:
        docker_args += ["-e", "COMMAND=%s" % ' '.join(args.command)]
    # Add package names to the environment
    if args.package:
        packages = ' '.join(args.package)
        docker_args += ['-e', "PACKAGES=%s" % packages]
    # Copy all the RPMs to the mount directory
    srpm_mount_dir = None
    if args.srpm:
        srpm_mount_dir = make_mount_dir()
        copy_srpms(srpm_mount_dir, args.srpm)
        docker_args += ["-v", "%s:/mnt/docker-SRPMS" % srpm_mount_dir]
    if args.syslog:
        docker_args += ["-v", "/dev/log:/dev/log"]
    if args.name:
        docker_args += ["--name", args.name]
    if args.dir:
        for localdir in args.dir:
            if not os.path.isdir(localdir):
                print("Local directory argument is not a directory!")
                sys.exit(1)
            ext_path = os.path.abspath(localdir)
            int_path = os.path.basename(ext_path)
            docker_args += ["-v", "%s:/external/%s" % (ext_path, int_path)]
    if args.volume:
        for volume in args.volume:
            docker_args += ["-v", volume]
    if args.env:
        for env in args.env:
            docker_args += ["-e", env]

    # exec "docker run"
    docker_args += [CONTAINER, "/usr/local/bin/init-container.sh"]
    print >> sys.stderr, "Launching docker with args %s" % docker_args
    return_code = subprocess.call(docker_args)

    if srpm_mount_dir:
        print "Cleaning up temporary mount directory"
        shutil.rmtree(srpm_mount_dir)

    sys.exit(return_code)


if __name__ == "__main__":
    main()
