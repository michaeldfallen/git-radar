#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/radar-base.sh"

if is_repo; then
  printf " \x01\033[1;30m\x02git:(\x01\033[0m\x02"
  bash_color_remote_commits
  readable_branch_name
  bash_color_local_commits
  printf "\x01\033[1;30m\x02)\x01\033[0m\x02"
  bash_color_changes_status
  bash_stash_status
fi
