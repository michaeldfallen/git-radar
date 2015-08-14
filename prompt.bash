#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/git-base.sh"

command="$1"

if [[ "$command" == "--zsh" ]]; then
  git_prefix="%{$fg_bold[black]%}git:(%{$reset_color}"
  git_suffix="%{$fg_bold[black]%})%{$reset_color}"
  printf '%q' "$git_prefix$(zsh_color_remote_commits;branch_name;zsh_color_local_commits)$git_suffix$(zsh_color_changes_status)"
fi

if [[ "$command" == "--bash" || "$command" == "" ]]; then
  git_prefix="\033[1;30mgit:(\033[0m"
  git_suffix="\033[1;30m)\033[0m"
  echo "$git_prefix$(bash_color_remote_commits;readable_branch_name;bash_color_local_commits)$git_suffix$(bash_color_changes_status)"
fi
