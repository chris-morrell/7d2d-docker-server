#!/usr/bin/bash

set -e

# Run via `make config` this should have our docker volume mounted to
# /home/steam/.local/share/7DaysToDie/Saves/ and the host config dir
# bind-mounted to /home/steam/config/

cp /home/steam/config/serverconfig.xml /home/steam/.local/share/7DaysToDie/Saves/
cp /home/steam/config/serveradmin.xml /home/steam/.local/share/7DaysToDie/Saves/