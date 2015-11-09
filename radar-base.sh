NO_REMOTE_STATUS='--no-remote-status'

dot_git=""
stat_type=""
cwd=""
remote=""
rcfile_path="$HOME"

timethis() {
  cmd="$@"
  start=$(gdate +%s.%N)
  eval $cmd
  dur=$(echo "$(gdate +%s.%N) - $start" | bc)
  echo "$1 - $dur" >> $HOME/duration.dat
}

get_fetch_time() {
  if [ -f "$rcfile_path/.gitradarrc.bash" ]; then
    source "$rcfile_path/.gitradarrc.bash"
  elif [ -f "$rcfile_path/.gitradarrc.zsh" ]; then
    source "$rcfile_path/.gitradarrc.zsh"
  elif [ -f "$rcfile_path/.gitradarrc" ]; then
    source "$rcfile_path/.gitradarrc"
  fi

  FETCH_TIME="${GIT_RADAR_FETCH_TIME:-"$((5 * 60))"}"
  echo $FETCH_TIME

}

prepare_bash_colors() {
  if [ -f "$rcfile_path/.gitradarrc.bash" ]; then
    source "$rcfile_path/.gitradarrc.bash"
  elif [ -f "$rcfile_path/.gitradarrc" ]; then
    source "$rcfile_path/.gitradarrc"
  fi

  PRINT_F_OPTION=""

  COLOR_REMOTE_AHEAD="\x01${GIT_RADAR_COLOR_REMOTE_AHEAD:-"\\033[1;32m"}\x02"
  COLOR_REMOTE_BEHIND="\x01${GIT_RADAR_COLOR_REMOTE_BEHIND:-"\\033[1;31m"}\x02"
  COLOR_REMOTE_DIVERGED="\x01${GIT_RADAR_COLOR_REMOTE_DIVERGED:-"\\033[1;33m"}\x02"
  COLOR_REMOTE_NOT_UPSTREAM="\x01${GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM:-"\\033[1;31m"}\x02"

  COLOR_LOCAL_AHEAD="\x01${GIT_RADAR_COLOR_LOCAL_AHEAD:-"\\033[1;32m"}\x02"
  COLOR_LOCAL_BEHIND="\x01${GIT_RADAR_COLOR_LOCAL_BEHIND:-"\\033[1;31m"}\x02"
  COLOR_LOCAL_DIVERGED="\x01${GIT_RADAR_COLOR_LOCAL_DIVERGED:-"\\033[1;33m"}\x02"

  COLOR_CHANGES_STAGED="\x01${GIT_RADAR_COLOR_CHANGES_STAGED:-"\\033[1;32m"}\x02"
  COLOR_CHANGES_UNSTAGED="\x01${GIT_RADAR_COLOR_CHANGES_UNSTAGED:-"\\033[1;31m"}\x02"
  COLOR_CHANGES_CONFLICTED="\x01${GIT_RADAR_COLOR_CHANGES_CONFLICTED:-"\\033[1;33m"}\x02"
  COLOR_CHANGES_UNTRACKED="\x01${GIT_RADAR_COLOR_CHANGES_UNTRACKED:-"\\033[1;37m"}\x02"

  COLOR_STASH="\x01${GIT_RADAR_COLOR_STASH:-"\\033[1;33m"}\x02"

  COLOR_BRANCH="\x01${GIT_RADAR_COLOR_BRANCH:-"\\033[0m"}\x02"
  MASTER_SYMBOL="${GIT_RADAR_MASTER_SYMBOL:-"\\x01\\033[0m\\x02\\xF0\\x9D\\x98\\xAE\\x01\\033[0m\\x02"}"

  PROMPT_FORMAT="${GIT_RADAR_FORMAT:-" \\x01\\033[1;30m\\x02git:(\\x01\\033[0m\\x02%{remote: }%{branch}%{ :local}\\x01\\033[1;30m\\x02)\\x01\\033[0m\\x02%{ :stash}%{ :changes}"}"

  RESET_COLOR_LOCAL="\x01${GIT_RADAR_COLOR_LOCAL_RESET:-"\\033[0m"}\x02"
  RESET_COLOR_REMOTE="\x01${GIT_RADAR_COLOR_REMOTE_RESET:-"\\033[0m"}\x02"
  RESET_COLOR_CHANGES="\x01${GIT_RADAR_COLOR_CHANGES_RESET:-"\\033[0m"}\x02"
  RESET_COLOR_BRANCH="\x01${GIT_RADAR_COLOR_BRANCH_RESET:-"\\033[0m"}\x02"
  RESET_COLOR_STASH="\x01${GIT_RADAR_COLOR_STASH:-"\\033[0m"}\x02"
  
}

prepare_zsh_colors() {
  if [ -f "$rcfile_path/.gitradarrc.zsh" ]; then
    source "$rcfile_path/.gitradarrc.zsh"
  elif [ -f "$rcfile_path/.gitradarrc" ]; then
    source "$rcfile_path/.gitradarrc"
  fi

  PRINT_F_OPTION="%s"

  COLOR_REMOTE_AHEAD="%{${GIT_RADAR_COLOR_REMOTE_AHEAD:-$fg_bold[green]}%}"
  COLOR_REMOTE_BEHIND="%{${GIT_RADAR_COLOR_REMOTE_BEHIND:-$fg_bold[red]}%}"
  COLOR_REMOTE_DIVERGED="%{${GIT_RADAR_COLOR_REMOTE_DIVERGED:-$fg_bold[yellow]}%}"
  COLOR_REMOTE_NOT_UPSTREAM="%{${GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM:-$fg_bold[red]}%}"

  COLOR_LOCAL_AHEAD="%{${GIT_RADAR_COLOR_LOCAL_AHEAD:-$fg_bold[green]}%}"
  COLOR_LOCAL_BEHIND="%{${GIT_RADAR_COLOR_LOCAL_BEHIND:-$fg_bold[red]}%}"
  COLOR_LOCAL_DIVERGED="%{${GIT_RADAR_COLOR_LOCAL_DIVERGED:-$fg_bold[yellow]}%}"

  COLOR_CHANGES_STAGED="%{${GIT_RADAR_COLOR_CHANGES_STAGED:-$fg_bold[green]}%}"
  COLOR_CHANGES_UNSTAGED="%{${GIT_RADAR_COLOR_CHANGES_UNSTAGED:-$fg_bold[red]}%}"
  COLOR_CHANGES_CONFLICTED="%{${GIT_RADAR_COLOR_CHANGES_CONFLICTED:-$fg_bold[yellow]}%}"
  COLOR_CHANGES_UNTRACKED="%{${GIT_RADAR_COLOR_CHANGES_UNTRACKED:-$fg_bold[white]}%}"

  COLOR_STASH="%{${GIT_RADAR_COLOR_STASH:-$fg_bold[yellow]}%}"
  
  local italic_m="$(printf '\xF0\x9D\x98\xAE')"

  COLOR_BRANCH="%{${GIT_RADAR_COLOR_BRANCH:-$reset_color}%}"
  MASTER_SYMBOL="${GIT_RADAR_MASTER_SYMBOL:-"%{$reset_color%}$italic_m%{$reset_color%}"}"

  PROMPT_FORMAT="${GIT_RADAR_FORMAT:-" %{$fg_bold[grey]%}git:(%{$reset_color%}%{remote: }%{branch}%{ :local}%{$fg_bold[grey]%})%{$reset_color%}%{ :stash}%{ :changes}"}"

  RESET_COLOR_LOCAL="%{${GIT_RADAR_COLOR_LOCAL_RESET:-$reset_color}%}"
  RESET_COLOR_REMOTE="%{${GIT_RADAR_COLOR_REMOTE_RESET:-$reset_color}%}"
  RESET_COLOR_CHANGES="%{${GIT_RADAR_COLOR_CHANGES_RESET:-$reset_color}%}"
  RESET_COLOR_BRANCH="%{${GIT_RADAR_COLOR_BRANCH_RESET:-$reset_color}%}"
  RESET_COLOR_STASH="%{${GIT_RADAR_COLOR_STASH:-$reset_color}%}"
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

stat_type() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat_type="gstat"
  else
    stat_type="stat"
  fi
  printf '%s' $stat_type
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
    printf '%s' "$($(stat_type) -c%Y "$(dot_git)/lastupdatetime" 2>/dev/null || printf '%s' "0")"
  fi
}

time_now() {
  printf '%s' "$(date +%s)"
}

time_to_update() {
  last_time_updated="${1:-$FETCH_TIME}"
  if is_repo; then
    local timesincelastupdate="$(($(time_now) - $(timestamp)))"
    if (( $timesincelastupdate > $last_time_updated )); then
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
  # Gives $FETCH_TIME a value
  get_fetch_time

  if time_to_update $FETCH_TIME; then
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

remote_branch_name() {
  local localRef="$(branch_name)"
  local remote="$(git config --get "branch.$localRef.remote")"
  if [[ -n $remote ]]; then
    local remoteBranch="$(git config --get "branch.${localRef}.merge" | sed -e 's/^refs\/heads\///')"
    if [[ -n $remoteBranch ]]; then
      printf '%s/%s' $remote $remoteBranch
      return 0
    else
        return 1
    fi
  else
    return 1
  fi
}

commits_behind_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    git rev-list --left-only --count ${remote_branch}...HEAD 2>/dev/null
  else
    printf '%s' "0"
  fi
}

commits_ahead_of_remote() {
  remote_branch=${1:-"$(remote_branch_name)"}
  if [[ -n "$remote_branch" ]]; then
    git rev-list --right-only --count ${remote_branch}...HEAD 2>/dev/null
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

color_changes_status() {
  local separator="${1:- }"

  local porcelain="$(porcelain_status)"
  local changes=""

  if [[ -n "$porcelain" ]]; then
    local staged_changes="$(staged_status "$porcelain" "$COLOR_CHANGES_STAGED" "$RESET_COLOR_CHANGES")"
    local unstaged_changes="$(unstaged_status "$porcelain" "$COLOR_CHANGES_UNSTAGED" "$RESET_COLOR_CHANGES")"
    local untracked_changes="$(untracked_status "$porcelain" "$COLOR_CHANGES_UNTRACKED" "$RESET_COLOR_CHANGES")"
    local conflicted_changes="$(conflicted_status "$porcelain" "$COLOR_CHANGES_CONFLICTED" "$RESET_COLOR_CHANGES")"
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
  printf $PRINT_F_OPTION "${changes:1}"
}

bash_color_changes_status() {
  color_changes_status
}

zsh_color_changes_status() {
  color_changes_status
}

color_local_commits() {
  local green_ahead_arrow="${COLOR_LOCAL_AHEAD}↑$RESET_COLOR_LOCAL"
  local red_behind_arrow="${COLOR_LOCAL_BEHIND}↓$RESET_COLOR_LOCAL"
  local yellow_diverged_arrow="${COLOR_LOCAL_DIVERGED}⇵$RESET_COLOR_LOCAL"

  local local_commits=""
  if remote_branch="$(remote_branch_name)"; then
    local_ahead="$(commits_ahead_of_remote "$remote_branch")"
    local_behind="$(commits_behind_of_remote "$remote_branch")"

    if [[ "$local_behind" -gt "0" && "$local_ahead" -gt "0" ]]; then
      local_commits="$local_behind$yellow_diverged_arrow$local_ahead"
    elif [[ "$local_behind" -gt "0" ]]; then
      local_commits="$local_behind$red_behind_arrow"
    elif [[ "$local_ahead" -gt "0" ]]; then
      local_commits="$local_ahead$green_ahead_arrow"
    fi
  fi
  printf $PRINT_F_OPTION "$local_commits"
}

bash_color_local_commits() {
  color_local_commits
}

zsh_color_local_commits() {
  color_local_commits
}

color_remote_commits() {
  local green_ahead_arrow="${COLOR_REMOTE_AHEAD}←$RESET_COLOR_REMOTE"
  local red_behind_arrow="${COLOR_REMOTE_BEHIND}→$RESET_COLOR_REMOTE"
  local yellow_diverged_arrow="${COLOR_REMOTE_DIVERGED}⇄$RESET_COLOR_REMOTE"
  local not_upstream="${COLOR_REMOTE_NOT_UPSTREAM}⚡$RESET_COLOR_REMOTE"

  if remote_branch="$(remote_branch_name)"; then
    remote_ahead="$(remote_ahead_of_master "$remote_branch")"
    remote_behind="$(remote_behind_of_master "$remote_branch")"

    if [[ "$remote_behind" -gt "0" && "$remote_ahead" -gt "0" ]]; then
      remote="$MASTER_SYMBOL $remote_behind $yellow_diverged_arrow $remote_ahead"
    elif [[ "$remote_ahead" -gt "0" ]]; then
      remote="$MASTER_SYMBOL $green_ahead_arrow $remote_ahead"
    elif [[ "$remote_behind" -gt "0" ]]; then
      remote="$MASTER_SYMBOL $remote_behind $red_behind_arrow"
    fi
  else
    remote="upstream $not_upstream"
  fi

  printf $PRINT_F_OPTION "$remote"
}

bash_color_remote_commits() {
  color_remote_commits
}

zsh_color_remote_commits() {
  color_remote_commits
}

readable_branch_name() {
  if is_repo; then
    printf $PRINT_F_OPTION "$COLOR_BRANCH$(branch_name || printf '%s' "detached@$(commit_short_sha)")$RESET_COLOR_BRANCH"
  fi
}

zsh_readable_branch_name() {
  readable_branch_name
}

bash_readable_branch_name() {
  readable_branch_name
}

show_remote_status() {
  if [[ $@ == *$NO_REMOTE_STATUS* ]]; then
    return 1 # don't show the git remote status
  fi
  return 0
}

stashed_status() {
  printf '%s' "$(git stash list | wc -l 2>/dev/null | grep -oEi '[0-9][0-9]*')"
}

stash_status() {
  local number_stashes="$(stashed_status)"
  if [ $number_stashes -gt 0 ]; then
    printf $PRINT_F_OPTION "${number_stashes}${COLOR_STASH}≡${RESET_COLOR_STASH}"
  fi
}

render_prompt() {
  output="$PROMPT_FORMAT"
  branch_sed=""
  remote_sed=""
  local_sed=""
  changes_sed=""
  stash_sed=""


  if_pre="%\{([^%{}]{1,}:){0,1}"
  if_post="(:[^%{}]{1,}){0,1}\}"
  sed_pre="%{\(\([^%^{^}]*\)\:\)\{0,1\}"
  sed_post="\(\:\([^%^{^}]*\)\)\{0,1\}}"

  if [[ $output =~ ${if_pre}remote${if_post} ]]; then
    remote_result="$(color_remote_commits)"
    if [[ -n "$remote_result" ]]; then
      remote_sed="s/${sed_pre}remote${sed_post}/\2${remote_result}\4/"
    else
      remote_sed="s/${sed_pre}remote${sed_post}//"
    fi
  fi
  if [[ $PROMPT_FORMAT =~ ${if_pre}branch${if_post} ]]; then
    branch_result="$(readable_branch_name | sed -e 's/\//\\\//g')"
    if [[ -n "$branch_result" ]]; then
      branch_sed="s/${sed_pre}branch${sed_post}/\2${branch_result}\4/"
    else
      branch_sed="s/${sed_pre}branch${sed_post}//"
    fi
  fi
  if [[ $PROMPT_FORMAT =~ ${if_pre}local${if_post} ]]; then
    local_result="$(color_local_commits)"
    if [[ -n "$local_result" ]]; then
      local_sed="s/${sed_pre}local${sed_post}/\2$local_result\4/"
    else
      local_sed="s/${sed_pre}local${sed_post}//"
    fi
  fi
  if [[ $PROMPT_FORMAT =~ ${if_pre}changes${if_post} ]]; then
    changes_result="$(color_changes_status)"
    if [[ -n "$changes_result" ]]; then
      changes_sed="s/${sed_pre}changes${sed_post}/\2${changes_result}\4/"
    else
      changes_sed="s/${sed_pre}changes${sed_post}//"
    fi
  fi
  if [[ $PROMPT_FORMAT =~ ${if_pre}stash${if_post} ]]; then
    stash_result="$(stash_status)"
    if [[ -n "$stash_result" ]]; then
      stash_sed="s/${sed_pre}stash${sed_post}/\2${stash_result}\4/"
    else
      stash_sed="s/${sed_pre}stash${sed_post}//"
    fi
  fi

  printf '%b' "$output" | sed \
                            -e "$remote_sed" \
                            -e "$branch_sed" \
                            -e "$changes_sed" \
                            -e "$local_sed" \
                            -e "$stash_sed"
}
