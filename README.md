# xenserver-build-env
This docker config and collection of supporting scripts allows for creating
a docker container to work on and build a XenServer package from an SRPM. It
will build a Docker container with the right build environment (including some
useful tools) and then install all of the build-dependencies of the given
pacakge. You will then be in a chroot from which you can clone and build the
source.

By default, the container references a yum repository that comes from the
nightly snapshot uploads to xenserver.org.

## Configuration

You'll need to install docker. Follow the instructions for your platform on
https://www.docker.com/

## Building

Either build the docker image yourself:

```
docker build -t xenserver/xenserver-build-env .
```

or pull from the Docker Hub:

```
docker pull xenserver/xenserver-build-env
```

## Building packages

Install the dependencies of the package using yum:

```sh
yum-builddep xapi
```

then either download the SRPM using yumdownloader:

```sh
yumdownloader --source xapi
rpmbuild --rebuild xapi*
```

or clone the source from github or xenbits:

```sh
git clone git://github.com/xapi-project/xen-api
cd xen-api
./configure
make
```

## Mounting repos from outside the container
If you'd like to develop using the tools on your host and preseve the changes
to source and revision control but still use the container for building, you
can do using by using a docker volume.

Once you have built your image you can run it with an extra argument to mount
a directory from your host to a suitable point inside the container. For
example, if I clone some repos into a directory on my host, say `/work/code/`,
then I can mount it inside the container as follows:

```sh
docker run -i -t -v /work/code:/mnt/repos -u $(id -u) <IMAGE> /bin/bash
```

The `-u` flag uses the right UID inside so that changes made in the container
are with the same UID as outside the container. Docker >=1.6 supports group IDs
as well and both the group and user can be referenced by name.

Then the following format is available to set the UID/GID:

```sh
-u, --user=                Username or UID (format: <name|uid>[:<group|gid>])
```
