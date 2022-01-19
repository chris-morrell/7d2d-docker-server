#!/usr/bin/bash

set -e

function cleanly_exit()
{
    # I forgot about Docker only sending SIGTERM to PID1 within the container.
    kill -s SIGINT $1
    while $(kill -0 $1 2>/dev/null); do
        sleep 1
    done
    exit 0
}

# Copy the config file out of our volume mount. It's possible we were reconfigured.
cp /home/steam/.local/share/7DaysToDie/Saves/serverconfig.xml /home/steam/7d2d/serverconfig.xml

# Start the server
export LD_LIBRARY_PATH=/home/steam/7d2d
./home/steam/7d2d/7DaysToDieServer.x86_64 \
    -configfile=/home/steam/7d2d/serverconfig.xml -batchmode -nographics -dedicated &

server_pid=$!

# Capture term and interrupt to gracefully kill 7d2d.
trap "cleanly_exit $server_pid" SIGTERM
trap "cleanly_exit $server_pid" SIGINT

wait
exit 0