#!/bin/bash

# makes sure all env variables are defined
set -eu

echo "[+] telegram"

curl --version
jq --version

# ONLY for local testing: "source" loads env variables
source "./data/telegram.secrets"

##############################

# global param: <DATA_PATH>
function count_messages {
  echo $(cat ${DATA_PATH} | jq '. | length')
}

# global param: <DATA_PATH>
function get_latest_offset {
  # expected format: [] or [{"update_id":123, ...}]
  # use "-r" to avoid printing quotes
  echo $(cat ${DATA_PATH} | jq -r '. | last | .update_id // ""')
}

function build_query_params {
  local OFFSET=$(get_latest_offset)

  # check if offset exists and increase it by 1
  [[ -z "${OFFSET}" ]] && echo "" || echo "?offset=$((${OFFSET} + 1))"
}

# global param: <TELEGRAM_API_TOKEN>
function build_url {
  local OFFSET_PARAM=$(build_query_params)

  echo "https://api.telegram.org/bot${TELEGRAM_API_TOKEN}/getUpdates${OFFSET_PARAM}"
}

function request_latest_messages {
  local REQUEST_URL=$(build_url)

  echo $(curl -s ${REQUEST_URL})
}

# global param: <TELEGRAM_FROM_ID>
function validate_messages {
  local RESPONSE=$(request_latest_messages)

  # sample response: "text" field is optional
  # {
  #   "ok": true,
  #   "result": [
  #    {
  #      "update_id": 123,
  #      "message": {
  #        "message_id": 42,
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
  echo ${RESPONSE} | jq -c --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} \
    '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID | tonumber)) ] |
      map({
        "update_id": .update_id,
        "message_text": [ try(.message.text) catch "" | gsub("\\s+";"\n") | splits("\n") ]
      })'
}

function parse_messages {
  local MESSAGES=$(validate_messages)

  # expected format: [] or [{"update_id":123,"message_text":["test"]}]

  # TODO
  echo $MESSAGES
}

function concat_messages {
  local VALUES=$1
  local OLD_VALUES="$(cat ${DATA_PATH} | jq '.')"

  # mandatory quotes on argjson value
  jq -n \
    --argjson OLD_MESSAGES "${OLD_VALUES}" \
    --argjson NEW_MESSAGES "${VALUES}" \
    '$OLD_MESSAGES + $NEW_MESSAGES' \
    > ${DATA_PATH}
}

##############################

function main {
  echo "[*] DATA_PATH=${DATA_PATH}"
  echo "[*] OFFSET=$(get_latest_offset)"
  echo "[*] COUNT=$(count_messages)"

  local MESSAGES=$(parse_messages)
  echo -e "[*] MESSAGES=\n${MESSAGES}"
  
  concat_messages "${MESSAGES}"

  echo "[*] NEW_OFFSET=$(get_latest_offset)"
  echo "[*] NEW_COUNT=$(count_messages)"
}

# TODO make paths configurable
# TODO update json structure for hugo i.e. url, tags, ...
main

echo "[-] telegram"
