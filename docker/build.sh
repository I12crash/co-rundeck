#!/bin/bash
VERSION=2.11.4
NAME="rundeck"

#docker build -t $NAME .
docker build -t $NAME:$VERSION .
docker tag $NAME:$VERSION $NAME:latest
