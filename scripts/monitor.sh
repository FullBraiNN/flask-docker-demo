SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"

POSTGRES_STATUS="UNKNOWN"
DOCKER_STATUS="UNKNOWN"
STATUS=0

DISK_USAGE=0
RAM_USAGE=0


#!/bin/bash

STATUS=0

check_disk() {

    THRESHOLD=90

    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then
        STATUS=1
    fi

}

check_ram() {

    RAM_THRESHOLD=90

    RAM_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

    if [ "$RAM_USAGE" -ge "$RAM_THRESHOLD" ]; then
        STATUS=1
    fi

}

check_docker() {

    DOCKER_STATUS="OK"

    CONTAINERS_DOWN=$(docker compose -f "$COMPOSE_FILE" ps --services --filter status=exited)

    if [ -n "$CONTAINERS_DOWN" ]; then
        DOCKER_STATUS="DOWN"
        STATUS=1
    fi

}

check_postgres() {

    POSTGRES_STATUS="OK"

    if ! docker compose -f "$COMPOSE_FILE" exec -T postgres pg_isready >/dev/null 2>&1; then

        POSTGRES_STATUS="DOWN"

        STATUS=1

    fi

}

print_report() {

    echo "DISK_USAGE=$DISK_USAGE"
    echo "RAM_USAGE=$RAM_USAGE"
    echo "DOCKER_STATUS=$DOCKER_STATUS"
    echo "POSTGRES_STATUS=$POSTGRES_STATUS"

    if [ "$STATUS" -eq 0 ]; then
        echo "STATUS=OK"
    else
        echo "STATUS=WARNING"
    fi

}



main() {

    check_disk
    check_ram
    check_docker
    check_postgres

    print_report

    exit "$STATUS"

}

main
