#! /usr/bin/env bash

if [[ "$OSTYPE" == *darwin* ]]; then
  READLINK_CMD='greadlink'
else
  READLINK_CMD='readlink'
fi

dot="$(cd "$(dirname "$([ -L "$0" ] && $READLINK_CMD -f "$0" || echo "$0")")"; pwd)"

source $dot/radar-base.sh

if [[ -z "$@" ]]; then
  fetch;
else
  fetch $1;
fi
