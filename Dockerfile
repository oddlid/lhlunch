FROM scratch
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

ADD archroot_2014-06-01.tar.xz /
ADD docker_arch_files/resolv.conf /etc/
ADD docker_arch_files/mirrorlist /etc/pacman.d/
ADD docker_arch_files/mkimage-arch-pacman.conf /etc/pacman.conf
RUN pacman-key --init; pacman-key --populate archlinux
RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S tar gzip make cpanminus perl-io-socket-ssl perl-datetime perl-ev
ENV PATH /usr/bin/vendor_perl/:/usr/bin/site_perl:$PATH
RUN cpanm Mojolicious
RUN mkdir /srv/lhlunch; chown http:http /srv/lhlunch
USER http
WORKDIR /srv/lhlunch
RUN curl -L -o - https://github.com/oddlid/lhlunch/tarball/master | tar --strip-components 1 -xzf -
EXPOSE 3000
CMD ["./run_in_docker.sh"]
