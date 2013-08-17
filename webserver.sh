#!/usr/bin/env bash

script="LHLunchWebService.pl"

if [ $1 == "start" ] ; then
   MOJO_REACTOR=Mojo::Reactor::Poll hypnotoad $script
elif [ $1 == "stop" ] ; then
   hypnotoad --stop $script
elif [ $1 == "status" ] ; then
   ps aux | grep $script | grep -v grep
else
   echo "Usage: $0 < start | stop >"
fi

