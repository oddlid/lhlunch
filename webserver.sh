#!/usr/bin/env bash

cd $(dirname $0)

script="LHLunchWebService.pl"

ht=/usr/bin/vendor_perl/hypnotoad

function _start() 
{
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
