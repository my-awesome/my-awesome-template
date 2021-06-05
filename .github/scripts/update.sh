#!/bin/bash

set -eu

echo "[+] update"

gh --version

##############################

GIT_USER_EMAIL="my-awesome-bot@users.noreply.github.com"
GIT_USER_NAME="my-awesome-bot"
GIT_BRANCH="telegram-${TIMESTAMP}"
PR_TITLE="[telegram-bot] $TIMESTAMP"
PR_MESSAGE="Updates telegram messages"

##############################

# 1 line string
MY_GIT=$(git status)

# updates only if there are changes
if [[ -z "${MY_GIT##*nothing to commit*}" ]]; then
  echo "[-] Skipped"
else
  echo "[-] Updating repository ..."

  # mandatory configs
  git config user.email $GIT_USER_EMAIL
  git config user.name $GIT_USER_NAME

  # must be on a different branch
  git checkout -b $GIT_BRANCH
  git add .
  git status

  # fails without quotes: "quote all values that have spaces"
  git commit -m "$PR_MESSAGE"
  git push origin $GIT_BRANCH
  gh pr create --head $GIT_BRANCH --title "$PR_TITLE" --body "$PR_MESSAGE"

  # automatically merge and cleanup
  gh pr merge $GIT_BRANCH --merge --delete-branch
fi

echo "[-] update"
