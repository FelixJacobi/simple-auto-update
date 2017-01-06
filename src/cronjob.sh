#!/bin/bash

# Simple Auto Update Version 1.0
# Copyright (C) 2016 Felix Jacobi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

set -e

# Use default language
export LC_ALL=C

# include common library
source /usr/lib/simple-auto-update/common.sh

function cleanUpAnacron() {
  if [ -e "/etc/cron.daily/simple-auto-update" ] && [ ! -d "/etc/cron.daily/simple-auto-update" ]; then
    rm -f "/etc/cron.daily/simple-auto-update"
  fi

  if [ -e "/etc/cron.weekly/simple-auto-update" ] && [ ! -d "/etc/cron.weekly/simple-auto-update" ]; then
    rm -f "/etc/cron.weekly/simple-auto-update"
  fi
}

function cleanUpCron() {
  if [ -e "/etc/cron.d/simple-auto-update" ] && [ ! -d "/etc/cron.d/simple-auto-update" ]; then
    rm -f /etc/cron.d/simple-auto-update
  fi
}

echo "Loading configuration ..."
loadConfig
echo "Writing cronjob file ..."

if [ "$CONF_USEANACRON" = "false" ]; then
  cleanUpAnacron

  echo > /etc/cron.d/simple-auto-update
  cat > /etc/cron.d/simple-auto-update << EOT
# Automatically generated. Do not change!
# To edit the time to run, edit the configuration file /etc/simple-auto-update.conf
# and run the following command:
#  /usr/lib/simple-auto-update/cronjob.sh

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

$CONF_RUNMINUTE $CONF_RUNHOUR * * $CONF_RUNDAY root /usr/sbin/simple-auto-update
EOT
else
  if [ "$CONF_RUNDAY" != "*" ]; then
    cleanUpAnacron
    ln -s "/usr/sbin/simple-auto-update" "/etc/cron.weekly/simple-auto-update"
  else
    if [ -e "/etc/cron.daily/simple-auto-update" ] && [ ! -d "/etc/cron.daily/simple-auto-update" ]; then
      rm -f "/etc/cron.daily/simple-auto-update"
    fi
    cleanUpAnacron
    ln -s "/usr/sbin/simple-auto-update" "/etc/cron.daily/simple-auto-update"
  fi

  cleanUpCron
fi
echo "Done."
exit
