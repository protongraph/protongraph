#!/bin/bash

id=$(docker ps | grep protongraph | awk '{ print $1 }')
docker stop $id && docker rm $id