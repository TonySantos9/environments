#!/bin/bash

# MySQL Docker Management Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to initialize or start MySQL container
init_mysql() {
    if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
        if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
            echo "Container '$CONTAINER_NAME' is already running."
        else
            echo "Starting container '$CONTAINER_NAME'..."
            docker start $CONTAINER_NAME
        fi
    else
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
}

# Function to stop MySQL container
stop_mysql() {
    echo "Stopping MySQL container..."
    docker stop $CONTAINER_NAME
    echo "MySQL container '$CONTAINER_NAME' stopped."
}

# Function to restart MySQL container
restart_mysql() {
    echo "Restarting MySQL container..."
    docker restart $CONTAINER_NAME
    echo "MySQL container '$CONTAINER_NAME' restarted."
}

# Function to create a backup of the MySQL database
backup_mysql() {
    mkdir -p $BACKUP_DIR
    TIMESTAMP=$(date +"%F_%H-%M-%S")
    BACKUP_FILE="$BACKUP_DIR/${MYSQL_DATABASE}_backup_$TIMESTAMP.sql"
    
    echo "Backing up database '$MYSQL_DATABASE' from container '$CONTAINER_NAME' to '$BACKUP_FILE'..."
    docker exec $CONTAINER_NAME mysqldump -u root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE > $BACKUP_FILE
    echo "Backup complete: $BACKUP_FILE"
}

# Function to restore a MySQL database from a backup
restore_mysql() {
    read -p "Enter the path to the backup file to restore: " BACKUP_FILE
    if [ -f "$BACKUP_FILE" ]; then
        echo "Restoring database '$MYSQL_DATABASE' from backup file '$BACKUP_FILE'..."
        docker exec -i $CONTAINER_NAME mysql -u root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE < $BACKUP_FILE
        echo "Database restore complete."
    else
        echo "Backup file '$BACKUP_FILE' not found."
    fi
}

# Function to connect to the MySQL database within the container
connect_mysql() {
    echo "Connecting to MySQL database '$MYSQL_DATABASE' on container '$CONTAINER_NAME'..."
    docker exec -it $CONTAINER_NAME mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE
}

connect_bash() {
    echo "Connecting to MySQL bash terminal on container '$CONTAINER_NAME'..."
    docker exec -it $CONTAINER_NAME bash
}


# Main script menu
case "$1" in
    init)
        init_mysql
        ;;
    start)
        init_mysql
        ;;
    stop)
        stop_mysql
        ;;
    restart)
        restart_mysql
        ;;
    backup)
        backup_mysql
        ;;
    restore)
        restore_mysql
        ;;
    connect)
        connect_mysql
        ;;
    bash)
        connect_bash
        ;;
    *)
        echo "Usage: $0 {init|start|stop|restart|backup|restore|connect|bash}"
        exit 1
esac
