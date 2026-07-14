#!/bin/bash

THRESHOLD=90

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then
    echo "STATUS=WARNING"
    exit 1
else
    echo "STATUS=OK"
    exit 0
fi
