#!/usr/bin/env bash
# Tip I picked up for having more control over what runs 
# in the container etc.
# Odd, 2014-07-01 10:15:31

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
/usr/bin/supervisorctl
while true; do
   echo "Detach with CTRL-p CTRL-q. Dropping to shell"
   sleep 1
   /usr/bin/bash
done
