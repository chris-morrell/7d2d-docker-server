# Base OS image
FROM ubuntu:latest as base
RUN apt update && apt upgrade --yes


# Intermediate container used to fetch the 7D2D server files.
FROM cm2network/steamcmd:latest as steamcmd
LABEL builder=true

# Download 7D2D server files
USER steam:steam
RUN mkdir -p /home/steam/7d2d
RUN /home/steam/steamcmd/steamcmd.sh \
	+force_install_dir /home/steam/7d2d \
	+login anonymous \
	+app_update 294420 \
	+quit


# Assemble final container image.
FROM base

# Duplicate user from steamcmd
RUN groupadd -g 1000 steam && useradd -m -u 1000 -g steam steam

# Copy over 7D2D server files
USER steam:steam
RUN mkdir -p /home/steam/7d2d
COPY --from=steamcmd /home/steam/7d2d /home/steam/7d2d

# Necessary ports to enable multiplayer
EXPOSE 26900-26902/udp
EXPOSE 26900/tcp
EXPOSE 8080-8081/tcp

# By default this container will use the default generated serveradmin.xml that is
# created on initial start at /home/steam/.local/share/7DaysToDie/Saves/serveradmin.xml
# This also uses the default serverconfig.xml located at /home/steam/7d2d/serverconfig.xml

# Create the Saves path so the volume mount doesn't require root permissions
RUN mkdir -p /home/steam/.local/share/7DaysToDie/Saves/ && chown steam:steam /home/steam/.local/share/7DaysToDie/Saves/

# /home/steam/config is used to bind-mount a host directory 
RUN mkdir -p /home/steam/config && chown steam:steam /home/steam/config

# Script used for generating initial config files, seeding config files
# into docker volume, and running the server.
COPY scripts/* /home/steam/

CMD export LD_LIBRARY_PATH=/home/steam/7d2d && \
    /home/steam/7d2d/7DaysToDieServer.x86_64 \
	-configfile=/home/steam/7d2d/serverconfig.xml \
	-batchmode -nographics -dedicated $@