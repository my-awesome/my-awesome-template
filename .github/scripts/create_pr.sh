#!/bin/bash

set -eu

echo "[+] create_pr"

gh --version

OUTPUT_PATH="data/"
GIT_BRANCH="telegram-${TIMESTAMP}"
GIT_MESSAGE="Updates ${OUTPUT_PATH}"

# TODO
# if no offset exists, skip

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

echo "[-] create_pr"
