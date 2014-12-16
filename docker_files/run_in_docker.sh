#!/usr/bin/env bash
# Small wrapper for starting up background jobs and webservice in Docker
# Odd E. Ebbesen <oddebb@gmail.com>, 2014-06-26 15:09:27

cd $(dirname $0)

DS=/tmp/lhlunch.json
LOG=/tmp/lhlunch.log
INTERVAL=${1:-1h}

# Run scraper in background, once per $INTERVAL
{
	while true; do 
		HOUR_NOW=$(date +%H)
		if [[ ( $HOUR_NOW -gt 7 ) && ( $HOUR_NOW -lt 12 ) ]]; then
			echo "Starting scrape at:" $(date --rfc-3339=seconds) >>$LOG
			$PWD/lhlunch_scraper.pl --nocache --output $DS
			echo "Scrape done at:" $(date --rfc-3339=seconds) >>$LOG
		else
			echo "Outside lunch hours, just sleeping:" $(date --rfc-3339=seconds) >>$LOG
		fi
		sleep $INTERVAL
	done
} &

# Start Mojolicious based webservice in foreground
LHL_JSONSRC=$DS hypnotoad -f $PWD/LHLunchWebService.pl

