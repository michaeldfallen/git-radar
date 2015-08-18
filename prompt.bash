#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/git-base.sh"

if is_repo; then
  git_prefix="\033[1;30mgit:(\033[0m"
  git_suffix="\033[1;30m)\033[0m"
  printf " $git_prefix$(bash_color_remote_commits;readable_branch_name;bash_color_local_commits)$git_suffix$(bash_color_changes_status)"
fi
