# What Do
This is some tooling to spin up a 7 Days to Die(7D2D) server with Docker and Docker Volumes. There isn't much that differentiates this project from others besides not shipping any 7D2D config files. This runs the server once to generate the config files and then sets you up to modify those config files and fire off a container using them.

# How Do
- `git clone git@github.com:chris-morrell/7d2d-docker-server.git`
- `make build` This will pull down the 7D2D server files from Steam. This is currently ~13gb unpacked.
- `make init` This will dump the serveradmin.xml and serverconfig.xml to $(pwd)/config
- At this point modify those config files. Add your admin whitelist, modify the server + password protect it if you want, configure the game settings for the experience you want.
- `make configure` This copies the config files out of $(pwd)/config into the docker volume `7d2dsaves`. This is how we'll persist our configuration + game state.
- `make deploy` This performs a docker run with the restart policy `unless-stopped`. In theory this will cause your container to relaunch on reboot or docker daemon restart.
- Connect and enjoy. The default port is 26900, your server should publish itself as well unless you configure it otherwise. If you need to use a different port range, correct those values in the serverconfig.xml and in the `make deploy` target.
- By default the web management is running on port 26899. You will want to set a password in serverconfig.xml to utilize this.
- `make stop` and `make start` do as you would expect.
- `make clean` currently blows EVERYTHING away. Be careful with that loaded gun.

# Who Do
I'm just a dude sharing some of my infrastructure. Maybe one other person will utilize this to play with some friends and tragically die at the first blood moon to spider zombies. Good luck.

# You Do
Feel free to contribute pull requests. I don't plan on supporting other container runtimes at this time.

# How Do(specifics)
This uses a multi-stage Dockerfile that pulls ubuntu:latest and cm2network/steamcmd:latest. The former is our base image for the 7D2D container. The latter is used as a convenient wrapper to pull the server files from Steam via steamcmd. These server files are copied over and the intermediate container is abandoned. A docker volume is used to persist your configuration files and game save data. In theory to update this you could rebuild via `make build`, and then redeploy the container with the new image to update. I haven't tested this.