#!/bin/bash

set -eu

echo "[+] poll_telegram"

curl --version
jq --version

# TODO
# check if offset exists and store it in and env
# if exists pass it as query parameter increased by 1
echo "[*] TIMESTAMP=${TIMESTAMP}"

TMP_OUTPUT_PATH="data/telegram-${TIMESTAMP}.json"
OUTPUT_PATH="data/telegram.json"

curl -s "https://api.telegram.org/bot${TELEGRAM_API_TOKEN}/getUpdates" | \
  jq --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})' \
  > $TMP_OUTPUT_PATH

# TODO
# save latest offset ONLY if there is a new message, otherwise upload old one
# merge "output paths" or create a new file
# delete tmp file
# >>> data/.telegram
echo "123" > .offset

echo "[-] poll_telegram"
