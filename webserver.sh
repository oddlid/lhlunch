#!/usr/bin/env bash

cd $(dirname $0)

script="LHLunchWebService.pl"

ht=/usr/bin/vendor_perl/hypnotoad

function _start() 
{
   # In order to make the webservice load data from a JSON file instead
   # of scraping directly, set env LHL_JSONSRC to a valid path when calling this script.
   # If the file does not exist at startup, the webservice will scrape on demand (cached),
   # but check on each request if the JSON file exists and switch to that if it does.
   MOJO_REACTOR=Mojo::Reactor::Poll $ht $script
}

function _stop() 
{
   $ht --stop $script
}

function _restart()
{
   _stop
   sleep 2
   _start
}

case "$1" in 
   start)
      _start
      ;;
   stop)
      _stop
      ;;
   restart)
      _restart
      ;;
   status)
      ps aux | grep $script | grep -v grep
      ;;
   *)
      echo "Usage: $0 < start | stop | restart | status >"
      ;;
esac
