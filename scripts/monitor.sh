SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"

LOG_FILE="/var/log/vextra/monitor.log"

FAIL_REASON=""

APP_STATUS="UNKNOWN"

SSL_STATUS="UNKNOWN"
SSL_DAYS_LEFT=0
DOMAIN="vextra.cloud"
SSL_WARNING_DAYS=15

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
        add_fail_reason "DISK"
    fi

}

check_ram() {

    RAM_THRESHOLD=90

    RAM_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

    if [ "$RAM_USAGE" -ge "$RAM_THRESHOLD" ]; then
        STATUS=1
        add_fail_reason "RAM"
    fi

}

check_docker() {

    DOCKER_STATUS="OK"

    CONTAINERS_DOWN=$(docker compose -f "$COMPOSE_FILE" ps --services --filter status=exited)

    if [ -n "$CONTAINERS_DOWN" ]; then
        DOCKER_STATUS="DOWN"
        STATUS=1
        add_fail_reason "DOCKER"
    fi

}

check_postgres() {

    POSTGRES_STATUS="OK"

    if ! docker compose -f "$COMPOSE_FILE" exec -T postgres pg_isready >/dev/null 2>&1; then

        POSTGRES_STATUS="DOWN"

        STATUS=1
        add_fail_reason "POSTGRES"

    fi

}

check_ssl() {

    SSL_EXPIRY=$(echo | openssl s_client \
        -servername "$DOMAIN" \
        -connect "$DOMAIN:443" 2>/dev/null \
        | openssl x509 -noout -enddate \
        | cut -d= -f2)

    SSL_EXPIRY_TS=$(date -d "$SSL_EXPIRY" +%s)

    NOW_TS=$(date +%s)

    SSL_DAYS_LEFT=$(( (SSL_EXPIRY_TS - NOW_TS) / 86400 ))

    SSL_STATUS="OK"

    if [ "$SSL_DAYS_LEFT" -le "$SSL_WARNING_DAYS" ]; then

        SSL_STATUS="WARNING"

        STATUS=1
        add_fail_reason "SSL"

    fi

}

check_http() {

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN/health)

    APP_STATUS="OK"

    if [ "$HTTP_STATUS" != "200" ]; then

        APP_STATUS="DOWN"

        STATUS=1
        add_fail_reason "APP"

    fi

}

add_fail_reason() {

    if [ -z "$FAIL_REASON" ]; then
        FAIL_REASON="$1"
    else
        FAIL_REASON="$FAIL_REASON,$1"
    fi

}

check_cpu() {

    THRESHOLD=90

    CPU_IDLE=$(top -bn1 | grep "%Cpu(s)" | awk '{print $8}')

    CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")

    if awk "BEGIN {exit !($CPU_USAGE >= $THRESHOLD)}"; then
        echo "WARNING: CPU usage is high."
        STATUS=1
    fi

}


check_load() {

    THRESHOLD=3

    LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')

    echo "LOAD_AVG=${LOAD_AVG}"

    if awk "BEGIN {exit !($LOAD_AVG >= $THRESHOLD)}"; then
        echo "WARNING: System load is high."
        STATUS=1
    fi

}


log() {

    if [ -d "$(dirname "$LOG_FILE")" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
    fi

}

print_report() {

    echo "DISK_USAGE=$DISK_USAGE"
    log "DISK_USAGE=$DISK_USAGE"

    echo "RAM_USAGE=$RAM_USAGE"
    log "RAM_USAGE=$RAM_USAGE"

    echo "DOCKER_STATUS=$DOCKER_STATUS"
    log "DOCKER_STATUS=$DOCKER_STATUS"

    echo "POSTGRES_STATUS=$POSTGRES_STATUS"
    log "POSTGRES_STATUS=$POSTGRES_STATUS"

    echo "SSL_DAYS_LEFT=$SSL_DAYS_LEFT"
    log "SSL_DAYS_LEFT=$SSL_DAYS_LEFT"

    echo "SSL_STATUS=$SSL_STATUS"
    log "SSL_STATUS=$SSL_STATUS"

    echo "APP_STATUS=$APP_STATUS"
    log "APP_STATUS=$APP_STATUS"

    echo "FAIL_REASON=$FAIL_REASON"
    log "FAIL_REASON=$FAIL_REASON"

    echo "CPU_USAGETTTTTTT=$CPU_USAGE"
    log "CPU_USAGETTTTTTT=$CPU_USAGE"

    echo "LOAD_AVG=$LOAD_AVG"
    log "LOAD_AVG=$LOAD_AVG"

    if [ "$STATUS" -eq 0 ]; then
        echo "STATUS=OK"
        log "STATUS=OK" 
    else
        echo "STATUS=WARNING"
        log "STATUS=WARNING" 
    fi
}



main() {

    check_disk
    check_ram
    check_docker
    check_postgres
    check_ssl
    check_http
    check_cpu
    check_load

    print_report

    exit "$STATUS"

}

main
