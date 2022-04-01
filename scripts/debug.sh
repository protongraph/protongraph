#!/bin/bash
# Allows us to step into a running protongraph container and launch a shell.
id=$(docker ps | grep protongraph | awk '{ print $1 }')
docker exec -it $id /bin/bash