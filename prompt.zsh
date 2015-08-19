#! /usr/bin/env zsh

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/radar-base.sh"

if is_repo; then
  autoload colors && colors
  printf '%s' "%{$fg_bold[black]%} git:(%{$reset_color%}"
  zsh_color_remote_commits
  printf '%s' "%{$fg[white]%}"
  readable_branch_name
  printf '%s' "%{$reset_color%}"
  zsh_color_local_commits
  printf '%s' "%{$fg_bold[black]%})%{$reset_color%}"
  zsh_color_changes_status
fi
