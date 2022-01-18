build:
# Build the container, remove the intermediate build stages.
	docker build --rm --tag "7daysdocker:latest" .
	docker image rm $(shell docker image ls --filter label=builder=true -q)

init:
# Used to run the container for the first time
# This lets the container initialize the docker volume
# and populate it with the generated XML files.
	mkdir -p config
	docker run --rm --name "7days-docker-init" --mount type=bind,source="$(shell pwd)/config",target=/home/steam/config 7daysdocker:latest /home/steam/init.sh

configure:
# This will copy config files from the config directory into
# the named docker volume that will be used to deploy.
	docker run --rm --name "7days-docker-config" --mount type=bind,source="$(shell pwd)/config",target=/home/steam/config --mount type=volume,source=7d2dsaves,destination=/home/steam/.local/share/7DaysToDie/Saves/ 7daysdocker:latest /home/steam/config.sh

run:
# Useful for a final check before a deploy.
	docker run -it --rm --name "7days-docker-run" --mount source=7d2dsaves,destination=/home/steam/.local/share/7DaysToDie/Saves/ -p 26900-26902:26900-26902/udp -p 26900:26900/tcp -p 26899:8080/tcp 7daysdocker:latest /home/steam/run.sh


deploy:
# Deploy the server such that it persists with reboots.
	docker run -d --restart unless-stopped --name "7days-docker-deploy" --mount source=7d2dsaves,destination=/home/steam/.local/share/7DaysToDie/Saves/ -p 26900-26902:26900-26902/udp -p 26900:26900/tcp -p 26899:8080/tcp 7daysdocker:latest /home/steam/run.sh

.SILENT:
stop:
# Tough debate between better communication vs /dev/null stderr.
# Opted to just communicate what is happening.
	ids=$(shell docker container ls --quiet --filter=name=7days-docker-deploy); \
	if [ -z "$$ids" ]; then \
		echo "No container to stop."; \
	else \
		echo "Stopping container."; \
		docker container stop --time 30 $$ids; \
	fi

start:
	docker container start 7days-docker-deploy

logs:
	docker container logs 7days-docker-deploy --follow

.SILENT:
clean: stop
	echo "Removing container 7days-docker-deploy"
	docker container rm -f 7days-docker-deploy 2> /dev/null
	echo "Removing volume 7d2dsaves"
	docker volume rm -f 7d2dsaves > /dev/null
	echo "Removing image 7daysdocker:latest"
	docker image rm -f 7daysdocker:latest 2> /dev/null