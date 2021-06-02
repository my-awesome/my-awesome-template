#!/bin/bash

set -eu

echo "[+] telegram"

curl --version
jq --version

curl -s "https://api.telegram.org/bot$TELEGRAM_API_TOKEN/getUpdates" | jq --arg TELEGRAM_FROM_ID $TELEGRAM_FROM_ID '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})'

echo "[-] telegram"
