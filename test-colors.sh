scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/radar-base.sh"

cd_to_tmp() {
  tmpfile="/tmp/git-prompt-tests-$(time_now)$1"
  mkdir -p "$tmpfile"
  cd "$tmpfile"
}

rm_tmp() {
  cd $scriptDir
  rm -rf /tmp/git-prompt-tests*
}

mock_zsh_colors() {
  fg_bold[green]=1
  fg_bold[red]=2
  fg_bold[yellow]=3
  fg_bold[white]=4

  reset_color=0
}

test_no_rcfile_zsh() {
  mock_zsh_colors
  prepare_zsh_colors

  assertEquals "$COLOR_REMOTE_AHEAD" "%{$fg_bold[green]%}"
  assertEquals "$COLOR_REMOTE_BEHIND" "%{$fg_bold[red]%}"
  assertEquals "$COLOR_REMOTE_DIVERGED" "%{$fg_bold[yellow]%}"
  assertEquals "$COLOR_REMOTE_NOT_UPSTREAM" "%{$fg_bold[red]%}"

  assertEquals "$COLOR_LOCAL_AHEAD" "%{$fg_bold[green]%}"
  assertEquals "$COLOR_LOCAL_BEHIND" "%{$fg_bold[red]%}"
  assertEquals "$COLOR_LOCAL_DIVERGED" "%{$fg_bold[yellow]%}"

  assertEquals "$COLOR_CHANGES_STAGED" "%{$fg_bold[green]%}"
  assertEquals "$COLOR_CHANGES_UNSTAGED" "%{$fg_bold[red]%}"
  assertEquals "$COLOR_CHANGES_CONFLICTED" "%{$fg_bold[yellow]%}"
  assertEquals "$COLOR_CHANGES_UNTRACKED" "%{$fg_bold[white]%}"

  assertEquals "$RESET_COLOR_LOCAL" "%{$reset_color%}"
  assertEquals "$RESET_COLOR_REMOTE" "%{$reset_color%}"
  assertEquals "$RESET_COLOR_CHANGES" "%{$reset_color%}"
}

test_with_env_vars_zsh() {
  export GIT_RADAR_COLOR_REMOTE_AHEAD="remote-ahead"
  export GIT_RADAR_COLOR_REMOTE_BEHIND="remote-behind"
  export GIT_RADAR_COLOR_REMOTE_DIVERGED="remote-diverged"
  export GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM="not-upstream"

  export GIT_RADAR_COLOR_LOCAL_AHEAD="local-ahead"
  export GIT_RADAR_COLOR_LOCAL_BEHIND="local-behind"
  export GIT_RADAR_COLOR_LOCAL_DIVERGED="local-diverged"

  export GIT_RADAR_COLOR_CHANGES_STAGED="changes-staged"
  export GIT_RADAR_COLOR_CHANGES_UNSTAGED="changes-unstaged"
  export GIT_RADAR_COLOR_CHANGES_CONFLICTED="changes-conflicted"
  export GIT_RADAR_COLOR_CHANGES_UNTRACKED="changes-untracked"

  export GIT_RADAR_COLOR_LOCAL_RESET="local-reset"
  export GIT_RADAR_COLOR_REMOTE_RESET="remote-reset"
  export GIT_RADAR_COLOR_CHANGES_RESET="change-reset"

  mock_zsh_colors
  prepare_zsh_colors

  assertEquals "$COLOR_REMOTE_AHEAD" "%{remote-ahead%}"
  assertEquals "$COLOR_REMOTE_BEHIND" "%{remote-behind%}"
  assertEquals "$COLOR_REMOTE_DIVERGED" "%{remote-diverged%}"
  assertEquals "$COLOR_REMOTE_NOT_UPSTREAM" "%{not-upstream%}"

  assertEquals "$COLOR_LOCAL_AHEAD" "%{local-ahead%}"
  assertEquals "$COLOR_LOCAL_BEHIND" "%{local-behind%}"
  assertEquals "$COLOR_LOCAL_DIVERGED" "%{local-diverged%}"

  assertEquals "$COLOR_CHANGES_STAGED" "%{changes-staged%}"
  assertEquals "$COLOR_CHANGES_UNSTAGED" "%{changes-unstaged%}"
  assertEquals "$COLOR_CHANGES_CONFLICTED" "%{changes-conflicted%}"
  assertEquals "$COLOR_CHANGES_UNTRACKED" "%{changes-untracked%}"

  assertEquals "$RESET_COLOR_LOCAL" "%{local-reset%}"
  assertEquals "$RESET_COLOR_REMOTE" "%{remote-reset%}"
  assertEquals "$RESET_COLOR_CHANGES" "%{change-reset%}"
}

. ./shunit/shunit2
