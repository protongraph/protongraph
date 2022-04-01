#!/bin/bash

# This script compiles Protongraph so as to allow it to run headlessly within a docker container.
# After you have run this script, you should be able to run Protongraph by executing the following command:
#
# "docker run protongraph"
#
# To shutdown the running container, run "docker ps -a" and "docker rm -f <container_id>"

# Obtain binaries (which are required to build the project or develop against it locally) if not present
./scripts/obtain_binaries.sh
# Build the compile image for compilation
docker build -f Dockerfile.compile . -t gcc-build
# Run the compile image in order to build the required headless binary
docker run --rm -v "$PWD":/usr/protongraph -w /usr/protongraph gcc-build make SHELL=/bin/bash
# Build the protongraph headless runtime image
make package_docker
