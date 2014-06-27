FROM scratch
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

# Create basic root FS
ADD archroot_2014-06-01.tar.xz /
# Customize some system config files
ADD docker_arch_files/resolv.conf /etc/
ADD docker_arch_files/mirrorlist /etc/pacman.d/
ADD docker_arch_files/mkimage-arch-pacman.conf /etc/pacman.conf
# Set the time right
RUN ln -s /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
# Prepare pacman
RUN pacman-key --init; pacman-key --populate archlinux
# Update system to latest
RUN pacman -Syu --noconfirm
# Install required packages
RUN pacman --noconfirm -S tar gzip make cpanminus perl-io-socket-ssl perl-datetime perl-ev supervisor procps-ng

# Add config for starting nginx in the background
ADD docker_arch_files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Overwrite default nginx config with a custom one just for the application
ADD docker_arch_files/nginx_lunch_proxy.conf /etc/nginx/nginx.conf

# Make sure CPAN module binaries are in $PATH
ENV PATH /usr/bin/vendor_perl/:/usr/bin/site_perl:$PATH
RUN cpanm Mojolicious
RUN mkdir /srv/lhlunch; chown http:http /srv/lhlunch

# Switch to runtime user and change working dir
USER http
WORKDIR /srv/lhlunch
# Get and unpack the application
RUN curl -L -o - https://github.com/oddlid/lhlunch/tarball/master | tar --strip-components 1 -xzf -
# Switch user back to root so supervisord will run privileged later
USER root

# Give access to nginx
EXPOSE 80

### Clean up ###
# Remove unneeded packages that just take up space in the image
RUN pacman --noconfirm -Rns systemd
# Clear out package cache
#RUN echo y | pacman -Scc --noconfirm
RUN rm -rf /var/cache/pacman/pkg/*

# supervisord starts nginx and the lhlunch application
CMD ["/usr/bin/supervisord", "-n"]
