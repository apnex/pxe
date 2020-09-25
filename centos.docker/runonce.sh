#!/bin/bash

if [[ -e /tmp/runonce ]]; then
	rm /tmp/runonce
	echo "TESTING" >> logger
	exec > /root/runonce.log 2>&1
	curl -fsSL http://labops.sh/docker/install | sh
	echo "FINISHED"
fi

exit
