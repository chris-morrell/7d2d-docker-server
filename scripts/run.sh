#!/usr/bin/bash

set -e

# Copy the config file out of our volume mount. It's possible we were reconfigured.
cp /home/steam/.local/share/7DaysToDie/Saves/serverconfig.xml /home/steam/7d2d/serverconfig.xml

# Start the server
export LD_LIBRARY_PATH=/home/steam/7d2d && /home/steam/7d2d/7DaysToDieServer.x86_64 \
    -configfile=/home/steam/7d2d/serverconfig.xml -batchmode -nographics -dedicated