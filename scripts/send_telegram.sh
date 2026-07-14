#!/bin/bash

set -e

MESSAGE="$1"

source /home/deploy/.config/vextra/telegram.env

curl -s \
-X POST \
"https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
-d chat_id="${TELEGRAM_CHAT_ID}" \
-d text="${MESSAGE}" \
> /dev/null
