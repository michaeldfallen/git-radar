#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/radar-base.sh"

if is_repo; then
  printf " \033[1;30mgit:(\033[0m"
  bash_color_remote_commits
  printf "\033[0;37m"
  readable_branch_name
  printf "\033[0m"
  bash_color_local_commits
  printf "\033[1;30m)\033[0m"
  bash_color_changes_status
fi
