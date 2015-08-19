#! /usr/bin/env zsh

dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/git-base.sh"

if is_repo; then
  autoload colors && colors
  git_prefix="%{$fg_bold[black]%} git:(%{$reset_color%}"
  git_suffix="%{$fg_bold[black]%})%{$reset_color%}"
  printf '%s' $git_prefix
  zsh_color_remote_commits
  branch_name
  zsh_color_local_commits
  printf '%s' $git_suffix
  zsh_color_changes_status
fi
