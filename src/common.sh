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

# Print out a string with a date
function stringWithTime {
  CURRENTTIME=$(date +"[%T]")
  echo "$CURRENTTIME $1"
}

# Print string if verbose mode is active
function printInVerboseMode {
  DATE=$(date +"[%Y-%m-%d]")
  OUTPUT=$(stringWithTime "$1")
  if [ "$VerboseMode" = "true" ]
  then
    echo "$OUTPUT"
  fi
  if [ -v LOGFILE ] && [ "$LOGFILE" != "" ]
  then
    echo "$DATE $OUTPUT" >> $LOGFILE
  fi
}

# Print a string to stderr
function printError {
  DATE=$(date +"[%Y-%m-%d]")
  OUTPUT=$(stringWithTime "$1")
  echo "$OUTPUT" >&2
  if [ -v LOGFILE ] && [ "$LOGFILE" != "" ]
  then
    echo "$DATE $OUTPUT" >> $LOGFILE
  fi

}

# Load Simple Auto Update Configuration
function loadConfig {
  if [ ! -r "/etc/simple-auto-update.conf" ]
  then
    printError "Warning: Configuration file was not found. Using default values."
  else
    source "/etc/simple-auto-update.conf"
  fi

  if [ -v EnableSimpleAutoUpdate ]
  then
    if [ "$EnableSimpleAutoUpdate" = "yes" ]
    then
      CONF_ENABLESIMPLEAUTOUPDATE=yes
    elif [ "$EnableSimpleAutoUpdate" = "no" ]
    then
      CONF_ENABLESIMPLEAUTOUPDATE=no
    else
      printError "Warning: Invalid value for Configuration variable \$EnableSimpleAutoUpdate. Using default value yes."
      CONF_ENABLESIMPLEAUTOUPDATE=yes
    fi
  else
    printError "Warning: Configuration variable \$EnableSimpleAutoUpdate not found in configuration file. Using default value yes."
    CONF_ENABLESIMPLEAUTOUPDATE=yes
  fi

  if [ -v FullUpgrade ]
  then
    if [ "$FullUpgrade" = "yes" ]
    then
      CONF_FULLUPGRADE=yes
    elif [ "$FullUpgrade" = "no" ]
    then
      CONF_FULLUPGRADE=no
    else
      printError "Warning: Invalid value for Configuration variable \$FullUpgrade. Using default value no."
      CONF_FULLUPGRADE=no
   fi
  else
    printError "Warning: Configuration variable \$FullUpgrade not found in configuration file. Using default value no."
    CONF_FULLUPGRADE=no
  fi

  if [ -v InstallNewConfigFiles ]
  then
    if [ "$InstallNewConfigFiles" = "yes" ]
    then
      CONF_INSTALLNEWCONFIGFILES=yes
    elif [ "$InstallNewConfigFiles" = "no" ]
    then
      CONF_INSTALLNEWCONFIGFILES=no
    else
      printError "Warning: Invalid value for Configuration variable \$InstallNewConfigFiles. Using default value no."
      CONF_INSTALLNEWCONFIGFILES=no
   fi
  else
    printError "Warning: Configuration variable \$InstallNewConfigFiles not found in configuration file. Using default value no."
    CONF_INSTALLNEWCONFIGFILES=no
  fi

  if [ -v Proxy ] && [ "$Proxy" != "" ]
  then
    CONF_PROXY="$Proxy"
  else
    CONF_PROXY=""
  fi

  if [ -v RunHour ]
  then
    if [ "$RunHour" -gt -1 ] && [ "$RunHour" -lt 24 ]
    then
      CONF_RUNHOUR="$RunHour"
    else
      printError "Warning: Invalid value for Configuration variable \$RunHour. Using default value 4."
      CONF_RUNHOUR=4
    fi
  else
    printError "Warning: Configuration variable \$RunHour not found in configuration file. Using default value 4."
    CONF_RUNHOUR=4
  fi

  if [ -v RunMinute ]
  then
    if [ "$RunMinute" -gt -1 ] && [ "$RunMinute" -lt 60 ]
    then
      CONF_RUNMINUTE="$RunMinute"
    else
      printError "Warning: Invalid value for Configuration variable \$RunMinute. Using default value 0."
      CONF_RUNMINUTE=0
    fi
  else
    printError "Warning: Configuration variable \$RunMinute not found in configuration file. Using default value 0."
    CONF_RUNMINUTE=0
  fi

  if [ -v RunDay ]
  then
    if [ "$RunDay" = "*" ]
    then
      CONF_RUNDAY="$RunDay"
    elif [ "$RunDay" -gt 0 ] && [ "$RunDay" -lt 8 ]
    then
      CONF_RUNDAY="$RunDay"
    else
      printError "Warning: Invalid value for Configuration variable \$RunDay. Using default value 1."
      CONF_RUNDAY=1
    fi
  else
    printError "Warning: Configuration variable \$RunDay not found in configuration file. Using default value 1."
    CONF_RUNDAY=1
  fi

  if [ -v UseAnacron ]
  then
    if [ "$UseAnacron" = "yes" ]
    then
      CONF_USEANACRON="true"
    elif [ "$UseAnacron" = "no" ]
    then
      CONF_USEANACRON="false"
    else
      printError "Warning: Invalid value for Configuration variable \$UseAnacron. Using default value no."
      CONF_USEANACRON=false
    fi
  else
    printError "Warning: Configuration variable \$UseAnacron not found in configuration file. Using default value no."
    CONF_USEANACRON=false
  fi
}
