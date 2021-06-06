#!/bin/bash

# makes sure all env variables are defined
set -eu

echo "[+] telegram"

curl --version
jq --version

# ONLY for local testing: "source" loads env variables
#source "./telegram.secrets"

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
# global param: <TIMESTAMP>
function validate_messages {
  local RESPONSE=$(request_latest_messages)

  # sample response
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
  # 
  # - filters messages from a specific user id
  # - "update_id" is used for the offset parameter
  # - "text" field is optional e.g. images
  # - converts whitespaces in new lines
  # - convert string to array splitting by new line
  echo ${RESPONSE} | jq -c \
    --arg TELEGRAM_FROM_ID ${TELEGRAM_FROM_ID} \
    --arg TIMESTAMP ${TIMESTAMP} \
    '[ .result[] | select(.message.from.id==($TELEGRAM_FROM_ID | tonumber)) ] |
      map({
        "update_id": .update_id,
        "timestamp": $TIMESTAMP,
        "message_text": [ try(.message.text) catch "" | gsub("\\s+";"\n") | splits("\n") ]
      })'
}

function parse_messages {
  local MESSAGES=$(validate_messages)

  # TODO this will keep all invalid messages
  # "url": (.message_text[] | select(. | startswith("http")) // "INVALID_URL")

  # - expected format: [{"update_id":123,"message_text":["hello","world"]}]
  # - discard messages with without text e.g. images: [{"update_id":123,"message_text":[""]}]
  # - set as "url" the first item that starts with "http" and convert everything else to a tag
  echo $MESSAGES | jq \
    --arg URL_FILTER "http" \ '. | map(select(.message_text[0] != "")) |
    map({
      "update_id": .update_id,
      "timestamp": .timestamp,
      "message_text": {
        "url": .message_text[] | select(. | startswith($URL_FILTER)),
        "tags": (
          [{ "name": "telegram", "auto": true }] +
          (.message_text | map(select(. | startswith($URL_FILTER) | not)) | map({ "name": . | ascii_downcase, "auto": false }))
        )
      }
    })'
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

# - when the offset parameter is passed, all the messages with a lower offeset/update_id will be deleted from telegram "queue"
# - messages are marked as read, always on the next execution, when the latest offset is passed
# - if there are only invalid messages always the latest known offset is passed, until a valid one is stored
# - telegram has a retention period, so eventually invalid or not processed messages will be dropped anyway
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

# TODO interactive bot
# TODO notify on telegram success/failure
main

echo "[-] telegram"
