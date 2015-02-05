set -e

debug_print() {
  debug=$1
  message=$2
  if [[ $debug == "debug" ]]; then
    echo $message
  fi
}

dot_git() {
  if [ -d .git ]; then
    echo ".git"
  else
    echo "$(git rev-parse --git-dir)"
  fi
}

git_root() {
  if [ -d .git ]; then
    echo "."
  else
    echo "$(git rev-parse --show-toplevel)"
  fi
}

record_timestamp() {
  touch "$(dot_git)/lastupdatetime"
}

timestamp() {
  echo "$(stat -f%m "$(dot_git)/lastupdatetime")"
}

time_now() {
  echo "$(date +%s)"
}

time_to_update() {
  timesincelastupdate="$(($(time_now) - $(timestamp)))"
  fiveminutes="$((5 * 60))"
  if (( "$timesincelastupdate" > "$5minutes" )); then
    # time to update return 0 (which is false)
    return 0
  else
    # not time to update return 1 (which is true)
    return 1
  fi
}

fetch_async() {
  debug="$1"
  if time_to_update; then
    debug_print $debug "Starting fetch"
    fetch $debug &
  else
    debug_print $debug "Didn't fetch"
  fi
}

fetch() {
  debug="$1"
  git fetch
  debug_print $debug "Finished fetch"
}
