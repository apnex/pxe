#!/bin/bash

mkdir -p ./output
docker build -f ipxe-build.docker -t apnex/docker-ipxe-build:latest .
docker cp $(docker create --rm apnex/docker-ipxe-build):/usr/src/ipxe/src/bin/ipxe.iso ./output/boot.iso
