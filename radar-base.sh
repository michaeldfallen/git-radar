NO_REMOTE_STATUS='--no-remote-status'

dot_git=""
cwd=""
remote=""

prepare_zsh_colors() {
  autoload colors && colors

  ZSH_COLOR_REMOTE_AHEAD="${GIT_RADAR_COLOR_ZSH_REMOTE_AHEAD:-$fg_bold[green]}"
  ZSH_COLOR_REMOTE_BEHIND="${GIT_RADAR_COLOR_ZSH_REMOTE_BEHIND:-$fg_bold[red]}"
  ZSH_COLOR_REMOTE_DIVERGED="${GIT_RADAR_COLOR_ZSH_REMOTE_DIVERGED:-$fg_bold[yellow]}"
  ZSH_COLOR_REMOTE_NOT_UPSTREAM="${GIT_RADAR_COLOR_ZSH_REMOTE_NOT_UPSTREAM:-$fg_bold[red]}"

  ZSH_COLOR_LOCAL_AHEAD="${GIT_RADAR_COLOR_ZSH_LOCAL_AHEAD:-$fg_bold[green]}"
  ZSH_COLOR_LOCAL_BEHIND="${GIT_RADAR_COLOR_ZSH_LOCAL_BEHIND:-$fg_bold[red]}"
  ZSH_COLOR_LOCAL_DIVERGED="${GIT_RADAR_COLOR_ZSH_LOCAL_DIVERGED:-$fg_bold[yellow]}"

  ZSH_RESET_COLOR_LOCAL="${GIT_RADAR_COLOR_ZSH_LOCAL_RESET:-$reset_color}"
  ZSH_RESET_COLOR_REMOTE="${GIT_RADAR_COLOR_ZSH_REMOTE_RESET:-$reset_color}"
  ZSH_RESET_COLOR_CHANGES="${GIT_RADAR_COLOR_ZSH_CHANGES_RESET:-$reset_color}"
}

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
    printf '%s' $dot_git
  elif [ -d .git ]; then
    dot_git=".git"
    printf '%s' $dot_git
  else
    dot_git="$(git rev-parse --git-dir 2>/dev/null)"
    printf '%s' $dot_git
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
    printf '%s' "$(pwd)"
  else
    printf '%s' "$(git rev-parse --show-toplevel 2>/dev/null)"
  fi
}

record_timestamp() {
  if is_repo; then
    touch "$(dot_git)/lastupdatetime"
  fi
}

timestamp() {
  if is_repo; then
    printf '%s' "$(stat -f%m "$(dot_git)/lastupdatetime" 2>/dev/null || printf '%s' "0")"
  fi
}

time_now() {
  printf '%s' "$(date +%s)"
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
    printf '%s' "$(git rev-parse --short HEAD 2>/dev/null)"
  fi
}

branch_name() {
  name="$(git symbolic-ref --short HEAD 2>/dev/null)"
  retcode="$?"
  if [[ "$retcode" == "0" ]]; then
    printf %s "$name"
  else
    return 1
  fi
}

branch_ref() {
  if is_repo; then
    printf '%s' "$(branch_name || commit_short_sha)"
  fi
}

readable_branch_name() {
  if is_repo; then
    printf '%s' "$(branch_name || printf '%s' "detached@$(commit_short_sha)")"
  fi
}

remote_branch_name() {
  local localRef="\/$(branch_name)$"
  if [[ -n "$localRef" ]]; then
    local remoteBranch="$(git for-each-ref --format='%(upstream:short)' refs/heads $localRef 2>/dev/null | grep $localRef)"
    if [[ -n $remoteBranch ]]; then
      printf '%s' $remoteBranch
      return 0
    else
      return 1
    fi
  fi
}

commits_behind_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    git rev-list --left-only --count ${remote_branch}...HEAD
  else
    printf '%s' "0"
  fi
}

commits_ahead_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    git rev-list --right-only --count ${remote_branch}...HEAD
  else
    printf '%s' "0"
  fi
}

remote_behind_of_master() {
  remote_branch=${1:-"$(remote_branch_name)"}
  tracked_remote="origin/master"
  if [[ -n "$remote_branch" && "$remote_branch" != "$tracked_remote" ]]; then
    git rev-list --left-only --count ${tracked_remote}...${remote_branch} 2>/dev/null || printf '%s' "0"
  else
    printf '%s' "0"
  fi
}

remote_ahead_of_master() {
  remote_branch=${1:-"$(remote_branch_name)"}
  tracked_remote="origin/master"
  if [[ -n "$remote_branch" && "$remote_branch" != "$tracked_remote" ]]; then
    git rev-list --right-only --count ${tracked_remote}...${remote_branch} 2>/dev/null || printf '%s' "0"
  else
    printf '%s' "0"
  fi
}

# Diacritic marks for overlaying an arrow over A D C etc
#us="\xE2\x83\x97{$reset_color%}"
#them="\xE2\x83\x96%{$reset_color%}"
#both="\xE2\x83\xA1%{$reset_color%}"

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
  printf '%s' "$(git status --porcelain 2>/dev/null)"
}

staged_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local prefix=${2:-""}
  local suffix=${3:-""}

  local staged_string=""
  local filesModified="$(printf '%s' "$gitStatus" | grep -oE "M[ACDRM ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesAdded="$(printf '%s' "$gitStatus" | grep -oE "A[MCDR ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesDeleted="$(printf '%s' "$gitStatus" | grep -oE "D[AMCR ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesRenamed="$(printf '%s' "$gitStatus" | grep -oE "R[AMCD ] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesCopied="$(printf '%s' "$gitStatus" | grep -oE "C[AMDR ] " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesAdded" ]; then
    staged_string="$staged_string$filesAdded${prefix}A${suffix}"
  fi
  if [ -n "$filesDeleted" ]; then
    staged_string="$staged_string$filesDeleted${prefix}D${suffix}"
  fi
  if [ -n "$filesModified" ]; then
    staged_string="$staged_string$filesModified${prefix}M${suffix}"
  fi
  if [ -n "$filesRenamed" ]; then
    staged_string="$staged_string$filesRenamed${prefix}R${suffix}"
  fi
  if [ -n "$filesCopied" ]; then
    staged_string="$staged_string$filesCopied${prefix}C${suffix}"
  fi
  printf '%s' "$staged_string"
}

conflicted_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local prefix=${2:-""}
  local suffix=${3:-""}
  local conflicted_string=""

  local filesUs="$(printf '%s' "$gitStatus" | grep -oE "[AD]U " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesThem="$(printf '%s' "$gitStatus" | grep -oE "U[AD] " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesBoth="$(printf '%s' "$gitStatus" | grep -oE "(UU|AA|DD) " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesUs" ]; then
    conflicted_string="$conflicted_string$filesUs${prefix}U${suffix}"
  fi
  if [ -n "$filesThem" ]; then
    conflicted_string="$conflicted_string$filesThem${prefix}T${suffix}"
  fi
  if [ -n "$filesBoth" ]; then
    conflicted_string="$conflicted_string$filesBoth${prefix}B${suffix}"
  fi
  printf '%s' "$conflicted_string"
}

unstaged_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local prefix=${2:-""}
  local suffix=${3:-""}
  local unstaged_string=""

  local filesModified="$(printf '%s' "$gitStatus" | grep -oE "[ACDRM ]M " | wc -l | grep -oEi '[1-9][0-9]*')"
  local filesDeleted="$(printf '%s' "$gitStatus" | grep -oE "[AMCR ]D " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesDeleted" ]; then
    unstaged_string="$unstaged_string$filesDeleted${prefix}D${suffix}"
  fi
  if [ -n "$filesModified" ]; then
    unstaged_string="$unstaged_string$filesModified${prefix}M${suffix}"
  fi
  printf '%s' "$unstaged_string"
}

untracked_status() {
  local gitStatus=${1:-"$(porcelain_status)"}
  local prefix=${2:-""}
  local suffix=${3:-""}
  local untracked_string=""

  local filesUntracked="$(printf '%s' "$gitStatus" | grep "?? " | wc -l | grep -oEi '[1-9][0-9]*')"

  if [ -n "$filesUntracked" ]; then
    untracked_string="$untracked_string$filesUntracked${prefix}A${suffix}"
  fi
  printf '%s' "$untracked_string"
}

bash_color_changes_status() {
  local separator="${1:- }"

  local porcelain="$(porcelain_status)"
  local changes=""

  if [[ -n "$porcelain" ]]; then
    local green_staged_prefix="\x01\033[1;32m\x02"
    local red_unstaged_prefix="\x01\033[1;31m\x02"
    local yellow_conflicted_prefix="\x01\033[1;33m\x02"
    local grey_untracked_prefix="\x01\033[1;37m\x02"
    local reset_suffix="\x01\033[0m\x02"

    local staged_changes="$(staged_status "$porcelain" "$green_staged_prefix" "$reset_suffix")"
    local unstaged_changes="$(unstaged_status "$porcelain" "$red_unstaged_prefix" "$reset_suffix")"
    local untracked_changes="$(untracked_status "$porcelain" "$grey_untracked_prefix" "$reset_suffix")"
    local conflicted_changes="$(conflicted_status "$porcelain" "$yellow_conflicted_prefix" "$reset_suffix")"
    if [[ -n "$staged_changes" ]]; then
      staged_changes="$separator$staged_changes"
    fi

    if [[ -n "$unstaged_changes" ]]; then
      unstaged_changes="$separator$unstaged_changes"
    fi

    if [[ -n "$conflicted_changes" ]]; then
      conflicted_changes="$separator$conflicted_changes"
    fi

    if [[ -n "$untracked_changes" ]]; then
      untracked_changes="$separator$untracked_changes"
    fi

    changes="$staged_changes$conflicted_changes$unstaged_changes$untracked_changes"
  fi
  printf "$changes"
}

zsh_color_changes_status() {
  local separator="${1:- }"

  local porcelain="$(porcelain_status)"
  local changes=""

  if [[ -n "$porcelain" ]]; then
    local staged_prefix="%{$fg_bold[green]%}"
    local unstaged_prefix="%{$fg_bold[red]%}"
    local conflicted_prefix="%{$fg_bold[yellow]%}"
    local untracked_prefix="%{$fg_bold[white]%}"
    local suffix="%{$reset_color%}"

    local staged_changes="$(staged_status "$porcelain" "$staged_prefix" "$suffix")"
    local unstaged_changes="$(unstaged_status "$porcelain" "$unstaged_prefix" "$suffix")"
    local untracked_changes="$(untracked_status "$porcelain" "$untracked_prefix" "$suffix")"
    local conflicted_changes="$(conflicted_status "$porcelain" "$conflicted_prefix" "$suffix")"
    if [[ -n "$staged_changes" ]]; then
      staged_changes="$separator$staged_changes"
    fi

    if [[ -n "$unstaged_changes" ]]; then
      unstaged_changes="$separator$unstaged_changes"
    fi

    if [[ -n "$conflicted_changes" ]]; then
      conflicted_changes="$separator$conflicted_changes"
    fi

    if [[ -n "$untracked_changes" ]]; then
      untracked_changes="$separator$untracked_changes"
    fi

    changes="$staged_changes$conflicted_changes$unstaged_changes$untracked_changes"
  fi
  printf %s "$changes"
}

bash_color_local_commits() {
  local separator="${1:- }"

  local green_ahead_arrow="\x01\033[1;32m\x02↑\x01\033[0m\x02"
  local red_behind_arrow="\x01\033[1;31m\x02↓\x01\033[0m\x02"
  local yellow_diverged_arrow="\x01\033[1;33m\x02⇵\x01\033[0m\x02"

  local local_commits=""
  if remote_branch="$(remote_branch_name)"; then
    local_ahead="$(commits_ahead_of_remote "$remote_branch")"
    local_behind="$(commits_behind_of_remote "$remote_branch")"

    if [[ "$local_behind" -gt "0" && "$local_ahead" -gt "0" ]]; then
      local_commits="$separator$local_behind$yellow_diverged_arrow$local_ahead"
    elif [[ "$local_behind" -gt "0" ]]; then
      local_commits="$separator$local_behind$red_behind_arrow"
    elif [[ "$local_ahead" -gt "0" ]]; then
      local_commits="$separator$local_ahead$green_ahead_arrow"
    fi
  fi
  printf "$local_commits"
}

zsh_color_local_commits() {
  local separator="${1:- }"

  local ahead_arrow="%{$ZSH_COLOR_LOCAL_AHEAD%}↑%{$ZSH_RESET_COLOR_LOCAL%}"
  local behind_arrow="%{$ZSH_COLOR_LOCAL_BEHIND%}↓%{$ZSH_RESET_COLOR_LOCAL%}"
  local diverged_arrow="%{$ZSH_COLOR_LOCAL_DIVERGED%}⇵%{$ZSH_RESET_COLOR_LOCAL%}"

  local local_commits=""
  if remote_branch="$(remote_branch_name)"; then
    local_ahead="$(commits_ahead_of_remote "$remote_branch")"
    local_behind="$(commits_behind_of_remote "$remote_branch")"

    if [[ "$local_behind" -gt "0" && "$local_ahead" -gt "0" ]]; then
      local_commits="$separator$local_behind$diverged_arrow$local_ahead"
    elif [[ "$local_behind" -gt "0" ]]; then
      local_commits="$separator$local_behind$behind_arrow"
    elif [[ "$local_ahead" -gt "0" ]]; then
      local_commits="$separator$local_ahead$ahead_arrow"
    fi
  fi
  printf %s "$local_commits"
}

bash_color_remote_commits() {
  local remote_master="\xF0\x9D\x98\xAE" # an italic m to represent master
  local green_ahead_arrow="\x01\033[1;32m\x02←\x01\033[0m\x02"
  local red_behind_arrow="\x01\033[1;31m\x02→\x01\033[0m\x02"
  local yellow_diverged_arrow="\x01\033[1;33m\x02⇄\x01\033[0m\x02"
  local not_upstream="\x01\033[1;31m\x02⚡\x01\033[0m\x02"

  if remote_branch="$(remote_branch_name)"; then
    remote_ahead="$(remote_ahead_of_master "$remote_branch")"
    remote_behind="$(remote_behind_of_master "$remote_branch")"

    if [[ "$remote_behind" -gt "0" && "$remote_ahead" -gt "0" ]]; then
      remote="$remote_master $remote_behind $yellow_diverged_arrow $remote_ahead "
    elif [[ "$remote_ahead" -gt "0" ]]; then
      remote="$remote_master $green_ahead_arrow $remote_ahead "
    elif [[ "$remote_behind" -gt "0" ]]; then
      remote="$remote_master $remote_behind $red_behind_arrow "
    fi
  else
    remote="upstream $not_upstream "
  fi

  printf "$remote"
}

zsh_color_remote_commits() {
  local remote_master="$(printf '\xF0\x9D\x98\xAE')" # an italic m to represent master
  local green_ahead_arrow="%{$ZSH_COLOR_REMOTE_AHEAD%}←%{$ZSH_RESET_COLOR_REMOTE%}"
  local red_behind_arrow="%{$ZSH_COLOR_REMOTE_BEHIND%}→%{$ZSH_RESET_COLOR_REMOTE%}"
  local yellow_diverged_arrow="%{$ZSH_COLOR_REMOTE_DIVERGED%}⇄%{$ZSH_RESET_COLOR_REMOTE%}"
  local not_upstream="%{$ZSH_COLOR_REMOTE_NOT_UPSTREAM%}⚡%{$ZSH_RESET_COLOR_REMOTE%}"

  if remote_branch="$(remote_branch_name)"; then
    remote_ahead="$(remote_ahead_of_master "$remote_branch")"
    remote_behind="$(remote_behind_of_master "$remote_branch")"

    if [[ "$remote_behind" -gt "0" && "$remote_ahead" -gt "0" ]]; then
      remote="$remote_master $remote_behind $yellow_diverged_arrow $remote_ahead "
    elif [[ "$remote_ahead" -gt "0" ]]; then
      remote="$remote_master $green_ahead_arrow $remote_ahead "
    elif [[ "$remote_behind" -gt "0" ]]; then
      remote="$remote_master $remote_behind $red_behind_arrow "
    fi
  else
    remote="upstream $not_upstream "
  fi

  printf %s "$remote"
}
show_remote_status() {
  if [[ $@ == *$NO_REMOTE_STATUS* ]]; then
    return 1 # don't show the git remote status
  fi
  return 0
}
