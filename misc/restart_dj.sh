#!/bin/sh
cd /var/www/go.wundercoach.net/current
if ! RAILS_ENV=production bin/delayed_job -n 2 status >/dev/null
then
  RAILS_ENV=production bin/delayed_job -n 2 restart
fi
