#! /usr/bin/env zsh

dot="$(cd "$(dirname "$0")"; pwd)"
args=$@
source "$dot/radar-base.sh"

if is_repo; then
  autoload colors && colors

  prepare_zsh_colors
  render_prompt
fi
