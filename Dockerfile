FROM oddlid/lobsterperl
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>

COPY \
		 LHLunch.pm \
		 LHLunchCache.pm \
		 LHLunchConfig.pm \
		 LHLunchWebService.pl \
		 lhlunch_scraper.pl \
		 docker_files/run_in_docker.sh \
		 /srv/lhlunch/ 

WORKDIR /srv/lhlunch
VOLUME ["/tmp"]
EXPOSE 3000

ENTRYPOINT ["/srv/lhlunch/run_in_docker.sh"]

