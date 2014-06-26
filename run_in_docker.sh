#!/usr/bin/env bash
# Small wrapper for starting up background jobs and webservice in Docker
# Odd E. Ebbesen <oddebb@gmail.com>, 2014-06-26 15:09:27

cd $(dirname $0)

DS=/tmp/lhlunch.json
INTERVAL=1h

# Run scraper in background, once per $INTERVAL
{
   while true; do 
      $PWD/lhlunch_scraper.pl --nocache --output $DS
      sleep $INTERVAL
   done
} &

# Start Mojolicious based webservice
LHL_JSONSRC=$DS hypnotoad -f $PWD/LHLunchWebService.pl

