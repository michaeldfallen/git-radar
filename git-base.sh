dot_git=""
cwd=""
remote=""

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
  if in_current_dir && [[ -n "$dot_git" ]]; then
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

branch_name() {
  if is_repo; then
    local localBranch="$(git symbolic-ref --short HEAD)"
    echo $localBranch
  fi
}

is_tracking_remote() {
  if [[ -n "$(remote_branch_name)" ]]; then
    return 0
  else
    return 1
  fi
}

remote_branch_name() {
  if is_repo; then
    local remoteBranch="$(git for-each-ref --format='%(upstream:short)' | grep "$(branch_name)")"
    if [[ -n $remoteBranch ]]; then
      echo $remoteBranch
      return 0
    else
      return 1
    fi
  fi
}

commits_behind_of_remote() {
  if is_tracking_remote; then
    set --
    set -- $(git rev-list --left-right --count $(remote_branch_name)...HEAD)
    behind=$1
    ahead=$2
    set --
    echo $behind
  else
    echo "0"
  fi
}

commits_ahead_of_remote() {
  if is_tracking_remote; then
    set --
    set -- $(git rev-list --left-right --count $(remote_branch_name)...HEAD)
    behind=$1
    ahead=$2
    set --
    echo $ahead
  else
    echo "0"
  fi
}

remote_behind_of_master() {
  if is_tracking_remote; then
    set --
    set -- $(git rev-list --left-right --count origin/master...$(remote_branch_name))
    behind=$1
    ahead=$2
    set --
    echo $behind
  else
    echo "0"
  fi
}

remote_ahead_of_master() {
  if is_tracking_remote; then
    set --
    set -- $(git rev-list --left-right --count origin/master...$(remote_branch_name))
    behind=$1
    ahead=$2
    set --
    echo $ahead
  else
    echo "0"
  fi
}

porcelain_status() {
  echo "$(git status --porcelain 2>/dev/null)"
}

untracked_files() {
  if is_repo; then
    git_status="$(porcelain_status)"
    untracked="$(echo "$git_status" | grep -p "?? " | wc -l | grep -oEi '[0-9][0-9]*')"
    echo "$untracked"
  fi
}
