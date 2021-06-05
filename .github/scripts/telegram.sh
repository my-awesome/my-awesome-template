#!/bin/bash

# makes sure all env variables are defined
set -eu

echo "[+] telegram"

curl --version
jq --version

##############################

DATA_PATH="./data"
PROPERTIES_PATH="${DATA_PATH}/telegram.properties"

# ONLY for local testing
#TIMESTAMP=$(date +%Y%m%d-%H%M%S)
#TELEGRAM_API_TOKEN=
#TELEGRAM_FROM_ID=
source "${DATA_PATH}/telegram.secrets"

OUTPUT_PATH="${DATA_PATH}/telegram.json"
TMP_OUTPUT_PATH="${DATA_PATH}/telegram-${TIMESTAMP}.json"

# "source" loads properties to env variables
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
  # check if offset exists and increase it by 1
  [[ -z "${CURRENT_OFFSET}" ]] && echo "" || echo "?offset=$((${CURRENT_OFFSET} + 1))"
}

function build_url {
  local OFFSET_PARAM=$(build_query_params)

  echo "${API_URL}/bot${TELEGRAM_API_TOKEN}/getUpdates${OFFSET_PARAM}"
}

function request_latest_messages {
  local REQUEST_URL=$(build_url)

  # sample response
  # {
  #   "ok": true,
  #   "result": [
  #    {
  #      "update_id": 60598210,
  #      "message": {
  #        "message_id": 23,
  #        "from": {
  #          "id": <TELEGRAM_FROM_ID>,
  #          "is_bot": false,
  #          "first_name": "<REDACTED>",
  #          "language_code": "en"
  #        },
  #        "chat": {
  #          "id": <TELEGRAM_FROM_ID>,
  #          "first_name": "<REDACTED>",
  #          "type": "private"
  #        },
  #        "date": 1622886765,
  #        "text": "test"
  #      }
  #    }
  #  ]
  # }
  # use "-c" to have 1 line  
  echo $(curl -s ${REQUEST_URL}) | jq -c --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} \
    '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID|tonumber)) ] | map({"update_id": .update_id, "message_text": .message.text})'
}

function get_latest_offset {
  # expected format: [{"update_id":123,"message_text":"hello"}]
  local JSON_STRING=$1

  # use "-r" to avoid printing quotes, hence string must be 1 line
  echo ${JSON_STRING} | jq -r '. | last | .update_id // ""'
}

function update_offset {
  local VALUE=$1

  if [[ -z "${VALUE}" ]]; then
    echo "[-] Offset NOT updated"
  else
    sed -i "s/^offset=.*/offset=${VALUE}/" ${PROPERTIES_PATH}
    echo "[-] Offset updated"
  fi
}

##############################

function main {
  echo "[+] telegram"

  MESSAGES=$(request_latest_messages)
  echo -e "[*] MESSAGES=\n${MESSAGES}"

  LATEST_OFFSET=$(get_latest_offset ${MESSAGES})
  echo "[*] LATEST_OFFSET=${LATEST_OFFSET}"

  update_offset "${LATEST_OFFSET}"
}

main

echo "[-] telegram"
