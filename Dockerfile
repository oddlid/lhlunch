FROM tianon/mojo
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

# Set up the LHLunch Mojolicious app to run in Docker.
# This time, I will not include nginx, only the app, so 
# the setup is more flexible, in case on wants to run nginx 
# on the host or in another container.


RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime


RUN mkdir /srv/lhlunch; chown http:http /srv/lhlunch

# Switch to runtime user and change working dir
USER http
WORKDIR /srv/lhlunch
# Get and unpack the application (could have just added the files directly as well...)
#RUN curl -L -o - https://github.com/oddlid/lhlunch/tarball/master | tar --strip-components 1 -xzf -
ADD LHLunch.pm /srv/lhlunch/
ADD LHLunchCache.pm /srv/lhlunch/
ADD LHLunchConfig.pm /srv/lhlunch/
ADD LHLunchWebService.pl /srv/lhlunch/
ADD lhlunch_scraper.pl /srv/lhlunch/
ADD run_in_docker.sh /srv/lhlunch/
# Switch user back to root so supervisord will run privileged later
USER root

# Give access to nginx
EXPOSE 3000
