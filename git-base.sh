dot_git=""
cwd=""

in_current_dir() {
  local wd="$(pwd)"
  if [[ "$wd" == $cwd ]]; then
    cwd="$wd"
    return 0
  else
    cwd="$wd"
    return 1
  fi
}

debug_print() {
  local debug=$1
  local message=$2
  if [[ $debug == "debug" ]]; then
    echo $message
  fi
}

dot_git() {
  if [[ in_current_dir && -n "$dot_git" ]]; then
    # cache dot_git to save calls to rev-parse
    echo $dot_git
  elif [ -d .git ]; then
    dot_git=".git"
    echo $dot_git
  else
    dot_git="$(git rev-parse --git-dir 2>/dev/null)"
    echo $dot_git
  fi
}

is_repo() {
  if [[ -n "$(dot_git)" ]]; then
    return 0
  else
    return 1
  fi
}

git_root() {
  if [ -d .git ]; then
    echo "$(pwd)"
  else
    echo "$(git rev-parse --show-toplevel 2>/dev/null)"
  fi
}

record_timestamp() {
  if is_repo; then
    touch "$(dot_git)/lastupdatetime"
  fi
}

timestamp() {
  if is_repo; then
    echo "$(stat -f%m "$(dot_git)/lastupdatetime")"
  fi
}

time_now() {
  echo "$(date +%s)"
}

time_to_update() {
  if is_repo; then
    local timesincelastupdate="$(($(time_now) - $(timestamp)))"
    local fiveminutes="$((5 * 60))"
    if (( "$timesincelastupdate" > "$5minutes" )); then
      # time to update return 0 (which is true)
      return 0
    else
      # not time to update return 1 (which is false)
      return 1
    fi
  else
    return 1
  fi
}

fetch_async() {
  local debug="$1"
  if time_to_update; then
    debug_print $debug "Starting fetch"
    fetch $debug &
  else
    debug_print $debug "Didn't fetch"
  fi
}

fetch() {
  local debug="$1"
  git fetch
  debug_print $debug "Finished fetch"
}
