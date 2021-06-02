#!/bin/bash

set -eu

echo "[+] telegram"

curl --version
jq --version
gh --version

TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
OUTPUT_PATH="data/telegram-${TIMESTAMP}.json"

# poll latest messages
# TODO store offset
curl -s "https://api.telegram.org/bot${TELEGRAM_API_TOKEN}/getUpdates" | \
  jq --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})' \
  > $OUTPUT_PATH

# must be on a different branch than main
#git checkout -b $OUTPUT_PATH
gh pr create --base main --title "[telegram-bot] $TIMESTAMP" --body "Adds file $OUTPUT_PATH" --head

echo "[-] telegram"
