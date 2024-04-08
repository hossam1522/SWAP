#!/bin/bash

sudo docker container prune -f
sudo docker network prune -f
sudo docker image prune -af
