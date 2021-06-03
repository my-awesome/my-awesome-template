#!/bin/bash

set -eu

# TODO split jobs/steps
echo "[+] telegram"

curl --version
jq --version
gh --version

TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
OUTPUT_PATH="data/telegram-${TIMESTAMP}.json"
GIT_BRANCH="telegram-${TIMESTAMP}"
GIT_MESSAGE="Adds file ${OUTPUT_PATH}"

# poll latest messages
# TODO store offset
curl -s "https://api.telegram.org/bot${TELEGRAM_API_TOKEN}/getUpdates" | \
  jq --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})' \
  > $OUTPUT_PATH

# mandatory configs
git config user.email "my-awesome-bot@users.noreply.github.com"
git config user.name "my-awesome-bot"
# must be on a different branch than main
git checkout -b $GIT_BRANCH
git add $OUTPUT_PATH
git status
# fails without quotes: "quote all values that have spaces"
git commit -m "$GIT_MESSAGE"
git push origin $GIT_BRANCH
gh pr create --head $GIT_BRANCH --title "[telegram-bot] $TIMESTAMP" --body "$GIT_MESSAGE" 

echo "[-] telegram"
