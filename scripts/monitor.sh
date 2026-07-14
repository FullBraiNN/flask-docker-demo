#!/bin/bash

STATUS=0


check_disk() {

    THRESHOLD=90

    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    echo "Disk Usage: ${DISK_USAGE}%"

    if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then

        echo "WARNING: Disk usage is high."

        STATUS=1

    fi

}


main() {

    check_disk

    if [ "$STATUS" -eq 0 ]; then
        echo "STATUS=OK"
    else
        echo "STATUS=WARNING"
    fi

    exit "$STATUS"

}

main
