#!/bin/bash

# makes sure all env variables are defined
set -eu

echo "[+] telegram"

curl --version
jq --version

##############################

DATA_PATH="./data"
PROPERTIES_PATH="${DATA_PATH}/telegram.properties"

# loads global variables: only for local testing
source "${DATA_PATH}/telegram.secrets"

OUTPUT_PATH="${DATA_PATH}/telegram.json"
TMP_OUTPUT_PATH="${DATA_PATH}/telegram-${TIMESTAMP}.json"

# source loads properties to env variables
source ${PROPERTIES_PATH}
API_URL=$api_url
CURRENT_OFFSET=$offset

echo "[*] TIMESTAMP=${TIMESTAMP}"
echo "[*] OUTPUT_PATH=${OUTPUT_PATH}"
echo "[*] TMP_OUTPUT_PATH=${TMP_OUTPUT_PATH}"
echo "[*] PROPERTIES_PATH=${PROPERTIES_PATH}"
echo "[*] API_URL=${API_URL}"
echo "[*] CURRENT_OFFSET=${CURRENT_OFFSET}"

##############################

function build_query_params {
  # check if offset exists increased it by 1
  [[ -z "${CURRENT_OFFSET}" ]] && echo "" || echo "?offset=$(($CURRENT_OFFSET + 1))"
}

function build_url {
  echo "${API_URL}/bot${TELEGRAM_API_TOKEN}/getUpdates$(build_query_params)"
}

function request_latest_messages {
  local REQUEST_URL=$(build_url)

  # use "-c" to have 1 line
  echo $(curl -s ${REQUEST_URL}) | jq -c --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} \
    '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})'
}

# format: [{"update_id":123,"message_text":"hello"}]
function get_latest_offset {
  local JSON_STRING=$1

  # use "-r" to avoid printing quotes
  echo ${JSON_STRING} | jq -r '. | last | .update_id // ""'
}

function update_offset {
  local VALUE=$1

  if [[ -z "${VALUE}" ]]; then
    echo "[-] Offset not updated"
  else
    sed -i "s/^offset=.*/offset=$VALUE/" ${PROPERTIES_PATH}
    echo "[-] Offset updated"
  fi
}

##############################

MESSAGES=$(request_latest_messages)
LATEST_OFFSET=$(get_latest_offset $MESSAGES)
update_offset "${LATEST_OFFSET}"

echo -e "[*] MESSAGES=\n${MESSAGES}"
echo "[*] LATEST_OFFSET=${LATEST_OFFSET}"

# TODO append new to array

echo "[-] telegram"
