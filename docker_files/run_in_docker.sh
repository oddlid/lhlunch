#!/usr/bin/env bash
# Small wrapper for starting up background jobs and webservice in Docker
# Odd E. Ebbesen <oddebb@gmail.com>, 2014-06-26 15:09:27

set -e

cd $(dirname $0) || exit 1

DS=${LHL_JSONF:-"/tmp/lhlunch.json"}
LOG=${LHL_LOGF:-"/tmp/lhlunch-$$.log"}

ACTION=${1:-"serve"}

_ts() {
	date --rfc-3339=seconds
}

_log() {
	echo $(_ts) ": $1" >>$LOG
}

if [[ "serve" = $ACTION ]]; then
	_log "Starting server..."
	LHL_JSONSRC=$DS hypnotoad -f $PWD/LHLunchWebService.pl
elif [[ "scrape" = $ACTION ]]; then
	_log "Starting scrape..."
	#$PWD/lhlunch_scraper.pl --nocache --output $DS
	#$PWD/lhlunch_scraper -sitefile $PWD/lh_restaurants_jq.json -output $DS
	$PWD/lhscrape.bin --url https://www.lindholmen.se/pa-omradet/dagens-lunch --log-file $LOG --log-level info --output $DS
	_log "Scrape done"
else
	_log "No known action given. Exec: $@"
	exec gosu root "$@"
fi

