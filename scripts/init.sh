#!/usr/bin/bash

set -e

# This exists to pull a copy of the serveradmin.xml and serverconfig.xml
# configuration files from a running 7d2d server.
# This removes the requirement of shipping the config files.

export LD_LIBRARY_PATH=/home/steam/7d2d
./home/steam/7d2d/7DaysToDieServer.x86_64 -configfile=/home/steam/7d2d/serverconfig.xml  -batchmode -nographics -dedicated -logfile /home/steam/config/output.log &
# Stash PID to kill
server_pid=$!

# Initial sleep to give the server a chance to spin up and write out the config files.
sleep 10

# Some hosts are very slow.
while [[ ! -e /home/steam/7d2d/serverconfig.xml && ! -e /home/steam/.local/share/7DaysToDie/Saves/serveradmin.xml ]];
do
    sleep 5
    echo "Waiting on config files to be written."
done

kill "$server_pid"

# The expectation is that /home/steam/config is a writable bind-mount.
cp /home/steam/7d2d/serverconfig.xml /home/steam/config/
cp /home/steam/.local/share/7DaysToDie/Saves/serveradmin.xml /home/steam/config/