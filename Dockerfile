FROM tianon/mojo
MAINTAINER Odd E. Ebbesen <oddebb@gmail.com>
RUN apt-get -y install git; mkdir /srv/app; chown www-data:www-data /srv/app
USER www-data
WORKDIR /srv/app
RUN git clone https://github.com/oddlid/lhlunch.git
WORKDIR lhlunch
EXPOSE 3000
CMD ["./run_in_docker.sh"]
