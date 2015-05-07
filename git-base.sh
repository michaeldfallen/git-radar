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

echodebug() {
  echo "$@" 1>&2
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
    echo "$(stat -f%m "$(dot_git)/lastupdatetime" 2>/dev/null || echo "0")"
  fi
}

time_now() {
  echo "$(date +%s)"
}

time_to_update() {
  if is_repo; then
    local timesincelastupdate="$(($(time_now) - $(timestamp)))"
    local fiveminutes="$((5 * 60))"
    if (( $timesincelastupdate > $fiveminutes )); then
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

fetch() {
  if time_to_update; then
    record_timestamp
    git fetch --quiet > /dev/null 2>&1
  fi
}

commit_short_sha() {
  if is_repo; then
    echo "$(git rev-parse --short HEAD)"
  fi
}

branch_name() {
  name="$(git symbolic-ref --short HEAD 2>/dev/null)"
  retcode="$?"
  if [[ "$retcode" == "0" ]]; then
    echo "$name"
  else
    return 1
  fi
}

branch_ref() {
  if is_repo; then
    echo "$(branch_name || commit_short_sha)"
  fi
}

readable_branch_name() {
  if is_repo; then
    echo "$(branch_name || echo "detached@$(commit_short_sha)")"
  fi
}

remote_branch_name() {
  local localRef="$(branch_name)"
  if [[ -n "$localRef" ]]; then
    local remoteBranch="$(git for-each-ref --format='%(upstream:short)' refs/heads $localRef 2>/dev/null | grep $localRef)"
    if [[ -n $remoteBranch ]]; then
      echo $remoteBranch
      return 0
    else
      return 1
    fi
  fi
}

commits_behind_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    set --
    set -- $(git rev-list --left-right --count ${remote_branch}...HEAD)
    behind=$1
    ahead=$2
    set --
    echo $behind
  else
    echo "0"
  fi
}

commits_ahead_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    set --
    set -- $(git rev-list --left-right --count ${remote_branch}...HEAD)
    behind=$1
    ahead=$2
    set --
    echo $ahead
  else
    echo "0"
  fi
}

remote_behind_of_master() {
  remote_branch=${1:-"$(remote_branch_name)"}
  tracked_remote="origin/master"
  if [[ -n "$remote_branch" && "$remote_branch" != "$tracked_remote" ]]; then
    set --
    set -- $(git rev-list --left-right --count ${tracked_remote}...${remote_branch} 2>/dev/null)
    behind=$1
    ahead=$2
    set --
    if [[ -n "$behind" ]]; then
      echo $behind
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

remote_ahead_of_master() {
  remote_branch=${1:-"$(remote_branch_name)"}
  tracked_remote="origin/master"
  if [[ -n "$remote_branch" && "$remote_branch" != "$tracked_remote" ]]; then
    set --
    set -- $(git rev-list --left-right --count ${tracked_remote}...${remote_branch} 2>/dev/null)
    behind=$1
    ahead=$2
    set --
    if [[ -n "$ahead" ]]; then
      echo $ahead
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

added="A%{$reset_color%}"
modified="M%{$reset_color%}"
deleted="D%{$reset_color%}"
renamed="R%{$reset_color%}"
us="U%{$reset_color%}"
them="T%{$reset_color%}"
both="B%{$reset_color%}"

staged="%{$fg_bold[green]%}"
unstaged="%{$fg_bold[red]%}"
conflicted="%{$fg_bold[yellow]%}"
untracked="%{$fg_bold[white]%}"

is_dirty() {
  if ! git rev-parse &> /dev/null; then
    #not in repo, thus not dirty
    return 1
  else
    #in repo, might be dirty
    if [[ -n "$(git ls-files --exclude-standard --others 2>/dev/null)" ]]; then
      #untracked files thus dirty
      return 0
    else
      #no untracked files
      if git show HEAD -- &> /dev/null; then
        #has a commit hash, thus not on an initial commit
        if ! git diff --quiet --ignore-submodules HEAD -- &> /dev/null; then
          #has differences thus dirty
          return 0
        else
          return 1
        fi
      else
        #no commit hash, thus can't use HEAD.
        #As it's inital commit we can just list the files.
        if [[ -n "$(ls -a -1 "$(git_root)" | grep -Ev '(\.|\.\.|\.git)')" ]]; then
          #files listed and no commit hash, thus changes
          return 0
        else
          return 1
        fi
      fi
    fi
  fi
}

porcelain_status() {
  echo "$(git status --porcelain 2>/dev/null)"
}

staged_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local staged_string=""
  local filesModified="$(echo "$gitStatus" | grep -p "M[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesAdded="$(echo "$gitStatus" | grep -p "A[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesDeleted="$(echo "$gitStatus" | grep -p "D[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesRenamed="$(echo "$gitStatus" | grep -p "R[A|M|C|D|U|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesAdded" ]; then
    staged_string="$staged_string$filesAdded$staged$added"
  fi
  if [ -n "$filesDeleted" ]; then
    staged_string="$staged_string$filesDeleted$staged$deleted"
  fi
  if [ -n "$filesModified" ]; then
    staged_string="$staged_string$filesModified$staged$modified"
  fi
  if [ -n "$filesRenamed" ]; then
    staged_string="$staged_string$filesRenamed$staged$renamed"
  fi
  echo "$staged_string"
}

conflicted_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local conflicted_string=""
  local filesConflictedUs="$(echo "$gitStatus" | grep -p "[A|M|C|D|R ]U " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesConflictedThem="$(echo "$gitStatus" | grep -p "U[A|M|C|D|R ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesConflictedBoth="$(echo "$gitStatus" | grep -p "UU " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesConflictedUs" ]; then
    conflicted_string="$conflicted_string$filesConflictedUs$conflicted$us"
  fi
  if [ -n "$filesConflictedBoth" ]; then
    conflicted_string="$conflicted_string$filesConflictedBoth$conflicted$both"
  fi
  if [ -n "$filesConflictedThem" ]; then
    conflicted_string="$conflicted_string$filesConflictedThem$conflicted$them"
  fi
  echo "$conflicted_string"
}

unstaged_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local unstaged_string=""
  local filesModified="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]M " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesDeleted="$(echo "$gitStatus" | grep -p "[A|M|C|D|U|R ]D " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesDeleted" ]; then
    unstaged_string="$unstaged_string$filesDeleted$unstaged$deleted"
  fi
  if [ -n "$filesModified" ]; then
    unstaged_string="$unstaged_string$filesModified$unstaged$modified"
  fi
  echo "$unstaged_string"
}

untracked_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local untracked_string=""
  local filesUntracked="$(echo "$gitStatus" | grep -p "?? " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesUntracked" ]; then
    untracked_string="$untracked_string$filesUntracked$untracked$added"
  fi
  echo "$untracked_string"
}
