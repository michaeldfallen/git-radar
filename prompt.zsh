#! /usr/bin/env zsh

dot="$(cd "$(dirname "$0")"; pwd)"
args=$@
source "$dot/radar-base.sh"

if is_repo; then
  autoload colors && colors

  prepare_zsh_colors
  printf '%s' "%{$fg_bold[black]%} git:(%{$reset_color%}"
  if show_remote_status $args; then
    color_remote_commits
  fi
  readable_branch_name
  color_local_commits
  printf '%s' "%{$fg_bold[black]%})%{$reset_color%}"
  color_changes_status
fi
