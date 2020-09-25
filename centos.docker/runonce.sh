#!/bin/bash

if [ -e /tmp/runonce ] then
	rm /tmp/runonce
	exec > /root/runonce.log 2>&1
	echo "LABOPS-STARTED" >> /root/logger
	curl -fsSL http://labops.sh/docker/install | sh
	echo "LABOPS-FINISHED" >> /root/logger
fi

exit
