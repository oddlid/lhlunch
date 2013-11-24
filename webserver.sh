#!/usr/bin/env bash

cd $(dirname $0)

script="LHLunchWebService.pl"

if [[ $1 == "start" ]] ; then
   MOJO_REACTOR=Mojo::Reactor::Poll /usr/bin/vendor_perl/hypnotoad $script
elif [[ $1 == "stop" ]] ; then
   hypnotoad --stop $script
elif [[ $1 == "status" ]] ; then
   ps aux | grep $script | grep -v grep
else
   echo "Usage: $0 < start | status | stop >"
fi

