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


print_report() {

    echo "DISK_USAGE=$DISK_USAGE"
    echo "RAM_USAGE=$RAM_USAGE"

    if [ "$STATUS" -eq 0 ]; then
        echo "STATUS=OK"
    else
        echo "STATUS=WARNING"
    fi

}

main() {

    check_disk
    check_ram

    print_report

    exit "$STATUS"

}

main
