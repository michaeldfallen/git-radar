#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
git_label=""
args=$@
source "$dot/radar-base.sh"

if is_repo; then
  if show_git_label $args; then
    git_label="git:"
  fi
  printf " \x01\033[1;30m\x02$git_label(\x01\033[0m\x02"
  if show_remote_status $args; then
    bash_color_remote_commits
  fi
  readable_branch_name
  bash_color_local_commits
  printf "\x01\033[1;30m\x02)\x01\033[0m\x02"
  bash_color_changes_status
fi
