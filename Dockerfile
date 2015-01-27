FROM oddlid/lobsterperl
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

COPY LHLunch.pm \
		 LHLunchCache.pm \
		 LHLunchConfig.pm \
		 LHLunchWebService.pl \
		 lhlunch_scraper.pl \
		 docker_files/run_in_docker.sh \
		 /srv/lhlunch/ 
WORKDIR /srv/lhlunch
VOLUME /tmp
VOLUME /srv/lhlunch
EXPOSE 3000

# You can pass the scan interval as a parameter when launching a container from this image.
# It takes the same format as "sleep" (as it's passed directly to sleep). The default is '1h' (one hour).
# One way to start a continer from this image, could be:
# docker run -d --name lhlunch -v /tmp/lhlunch:/tmp -p 3000:3000 oddlid/lhlunch 30m
ENTRYPOINT ["/srv/lhlunch/run_in_docker.sh"]
#CMD ["/bin/bash", "-l"]

