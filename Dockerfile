FROM perl:latest-threaded
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

# Set up the LHLunch Mojolicious app to run in Docker.
# This time, I will not include nginx, only the app, so 
# the setup is more flexible, in case on wants to run nginx 
# on the host or in another container.

ENV DEBIAN_FRONTEND noninteractive
#ENV PERL_CPANM_OPT --verbose
# Change the TZ here to match the TZ of your host
RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

# Upgrade bash to avoid shellshock bug
RUN apt-get -qq update
RUN apt-get install -y --only-upgrade bash
RUN apt-get -y clean

RUN cpanm DateTime
RUN cpanm Mojolicious
# The instructions up to here could be separated out to a another Dockerfile to build 
# a reusable Mojolicious image, which I might do some day.

RUN mkdir /srv/lhlunch
WORKDIR /srv/lhlunch

ADD LHLunch.pm /srv/lhlunch/
ADD LHLunchCache.pm /srv/lhlunch/
ADD LHLunchConfig.pm /srv/lhlunch/
ADD LHLunchWebService.pl /srv/lhlunch/
ADD lhlunch_scraper.pl /srv/lhlunch/
ADD docker_files/run_in_docker.sh /srv/lhlunch/

VOLUME /tmp
VOLUME /srv/lhlunch
EXPOSE 3000

# You can pass the scan interval as a parameter when launching a container from this image.
# It takes the same format as "sleep" (as it's passed directly to sleep). The default is '1h' (one hour).
# One way to start a continer from this image, could be:
# docker run -d --name lhlunch -v /tmp/lhlunch:/tmp -p 3000:3000 oddlid/lhlunch 30m
ENTRYPOINT ["/srv/lhlunch/run_in_docker.sh"]
#CMD ["/bin/bash", "-l"]
