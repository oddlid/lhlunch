FROM debian:jesse
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>
RUN apt-get update && apt-get install -yq libssl-dev curl 
RUN curl -SL http://cpanmin.us | perl - App::cpanminus
RUN cpanm EV IO::Socket::IP IO::Socket::SSL Mojolicious DateTime
RUN mkdir /srv/lhlunch; chown www-data:www-data /srv/lhlunch
USER www-data
WORKDIR /srv/lhlunch
RUN curl -OL https://github.com/oddlid/lhlunch/tarball/master | tar --strip-components 1 -xzf -
EXPOSE 3000
CMD ["./run_in_docker.sh"]
