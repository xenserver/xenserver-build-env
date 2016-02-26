## Internal Citrix Usage

Find an SRPM you'd like to build, either one you've built yourself, or
one from the
[build system](http://coltrane.uk.xensource.com/usr/groups/build/trunk/latest/binary-packages/RPMS/domain0/SRPMS/)

Start a container with a XenServer branch name, zero or more package names, and
zero or more SRPM paths like so:

```sh
./run.py -b trunk-ring3 -p xapi -s xenopsd-0.10.1-1+s0+0.10.1+10+gf2c98e0.el7.centos.src.rpm
```

The container will run yumdownloader to download the SRPM for each package
specified with -p, run yum-builddep against these SRPMs as well as the SRPMs
specified with -s, and drop you into an interactive shell.  In the above
example, the container will install the dependencies for xapi (as defined by
the SRPM in the standard repo) as well as dependencies for xenopsd (as defined
by the specified local SRPM).

You should then have all the dependencies to be able to build the components
whose SRPM or package name was specified above, e.g.

```sh
git clone git://github.com/xapi-project/xenopsd
cd xenopsd
./configure
make
```
