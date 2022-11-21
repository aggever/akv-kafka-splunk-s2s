#!/bin/bash

docker-compose stop
docker-compose rm -f

exit 0

# source ../scripts/colors.sh

# # Get all container names separated by spaces
# containers=$(docker ps --format '{{.Names}}' | tr '\n' ' ')

# [ -z "$containers" ] && { echo "Nothing to do"; exit 0; }

# echo -e "${Green}Stopping containers${Color_Off}"
# docker stop ${containers}

# echo -e "${Green}Removing containers${Color_Off}"
# docker rm -f ${containers}

# exit 0
