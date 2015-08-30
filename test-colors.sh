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

set_zsh_env_vars() {
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
}

test_with_env_vars_zsh() {
  set_zsh_env_vars
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

test_zsh_colors_local() {
  set_zsh_env_vars
  prepare_zsh_colors

  cd_to_tmp "remote"
  git init --bare --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "repo"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout -b master --quiet
  touch README
  git add README
  git commit -m "initial commit" --quiet
  git push --quiet -u origin master >/dev/null
  repoLocation="$(pwd)"

  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet

  assertEquals " 1%{local-ahead%}↑%{local-reset%}" "$(zsh_color_local_commits)"

  git push --quiet >/dev/null
  git reset --hard head^ --quiet >/dev/null

  assertEquals " 1%{local-behind%}↓%{local-reset%}" "$(zsh_color_local_commits)"

  echo "foo" > foo
  git add .
  git commit -m "new commit" --quiet

  assertEquals " 1%{local-diverged%}⇵%{local-reset%}1" "$(zsh_color_local_commits)"

  rm_tmp
}

test_zsh_colors_remote() {
  set_zsh_env_vars
  prepare_zsh_colors

  cd_to_tmp "remote"
  git init --bare --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "repo"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout -b master --quiet
  touch README
  git add README
  git commit -m "initial commit" --quiet
  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  git push --quiet -u origin master >/dev/null
  repoLocation="$(pwd)"

  git reset --hard head^ --quiet >/dev/null
  git checkout -b mybranch --quiet
  git push --quiet -u origin mybranch >/dev/null

  printf -v m '\xF0\x9D\x98\xAE'

  assertEquals "$m 1 %{remote-behind%}→%{remote-reset%} " "$(zsh_color_remote_commits)"

  echo "bar" > bar
  git add .
  git commit -m "new commit" --quiet
  git push --quiet >/dev/null

  assertEquals "$m 1 %{remote-diverged%}⇄%{remote-reset%} 1 " "$(zsh_color_remote_commits)"

  git pull origin master --quiet >/dev/null
  git push --quiet >/dev/null

  assertEquals "$m %{remote-ahead%}←%{remote-reset%} 2 " "$(zsh_color_remote_commits)"

  rm_tmp
}

test_zsh_colors_changes() {
  set_zsh_env_vars
  prepare_zsh_colors

  cd_to_tmp
  git init --quiet

  touch foo
  touch bar
  git add bar
  echo "bar" > bar
  untracked="1%{changes-untracked%}A%{change-reset%}"
  unstaged="1%{changes-unstaged%}M%{change-reset%}"
  staged="1%{changes-staged%}A%{change-reset%}"

  assertEquals " $staged $unstaged $untracked" "$(zsh_color_changes_status)"
}

. ./shunit/shunit2
