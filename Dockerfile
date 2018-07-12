FROM                                   centos:7.2.1511
LABEL maintainer.name="Jon Ludlam" \
      maintainer.email="jonathan.ludlam@citrix.com"

# Update yum.conf - not default!
COPY    files/yum.conf.xs              /etc/yum.conf.xs

# Add the Citrix yum repo and GPG key
RUN     mkdir -p /etc/yum.repos.d.xs
COPY    files/Citrix.repo.in           /tmp/Citrix.repo.in
COPY    files/RPM-GPG-KEY-Citrix-6.6   /etc/pki/rpm-gpg/RPM-GPG-KEY-Citrix-6.6

# Add the publicly available repo
COPY    files/xs.repo.in /tmp/xs.repo.in

# Fix invalid rpmdb checksum error with overlayfs, see https://github.com/docker/docker/issues/10180
RUN yum install -y yum-plugin-ovl

# Build requirements
RUN     yum install -y \
            gcc \
            gcc-c++ \
            git \
            make \
            mercurial \
            mock \
            rpm-build \
            rpm-python \
            sudo \
            yum-utils \
            epel-release

# Niceties
RUN     yum install -y \
            bash-completion \
            tig \
            tmux \
            vim \
            wget \
            which

# Install planex
#RUN     yum -y install https://xenserver.github.io/planex-release/release/rpm/el/planex-release-7-1.noarch.rpm
#RUN     cp /etc/yum.repos.d/planex-release.repo /etc/yum.repos.d.xs/planex-release.repo
#RUN     yum -y install planex

# OCaml in XS is slightly older than in CentOS
RUN     sed -i "/gpgkey/a exclude=ocaml*" /etc/yum.repos.d/Cent* /etc/yum.repos.d/epel*

# Set up the builder user
RUN     useradd builder \
        && echo "builder:builder" | chpasswd \
        && echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
        && usermod -G mock builder

RUN     mkdir -p /usr/local/bin
COPY    files/init-container.sh        /usr/local/bin/init-container.sh
