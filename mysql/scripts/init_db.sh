#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"


# Check if the MySQL container already exists
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    # Container exists
    echo "Container '$CONTAINER_NAME' already exists."

    # Check if it's running, and start if not
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "Container '$CONTAINER_NAME' is already running."
    else
        echo "Starting container '$CONTAINER_NAME'..."
        docker start $CONTAINER_NAME
    fi
else
    # Container does not exist, create and run a new one
    echo "Creating and starting a new MySQL container with name '$CONTAINER_NAME'..."
    docker run -d \
        --name $CONTAINER_NAME \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -e MYSQL_USER=$MYSQL_USER \
        -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
        -p 3306:3306 \
        mysql:latest

    echo "MySQL container '$CONTAINER_NAME' created and started."
fi
