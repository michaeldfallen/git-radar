#! /usr/bin/env bash

dot="$(cd "$(dirname "$0")"; pwd)"
args=$@
source "$dot/radar-base.sh"

if is_repo; then
  prepare_bash_colors
  render_prompt
fi
