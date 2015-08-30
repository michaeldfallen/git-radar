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

test_no_rcfile_bash() {
  reset_env_vars
  prepare_bash_colors

  assertEquals "$COLOR_REMOTE_AHEAD" "\x01\033[1;32m\x02"
  assertEquals "$COLOR_REMOTE_BEHIND" "\x01\033[1;31m\x02"
  assertEquals "$COLOR_REMOTE_DIVERGED" "\x01\033[1;33m\x02"
  assertEquals "$COLOR_REMOTE_NOT_UPSTREAM" "\x01\033[1;31m\x02"

  assertEquals "$COLOR_LOCAL_AHEAD" "\x01\033[1;32m\x02"
  assertEquals "$COLOR_LOCAL_BEHIND" "\x01\033[1;31m\x02"
  assertEquals "$COLOR_LOCAL_DIVERGED" "\x01\033[1;33m\x02"

  assertEquals "$COLOR_CHANGES_STAGED" "\x01\033[1;32m\x02"
  assertEquals "$COLOR_CHANGES_UNSTAGED" "\x01\033[1;31m\x02"
  assertEquals "$COLOR_CHANGES_CONFLICTED" "\x01\033[1;33m\x02"
  assertEquals "$COLOR_CHANGES_UNTRACKED" "\x01\033[1;37m\x02"

  assertEquals "$RESET_COLOR_LOCAL" "\x01\033[0m\x02"
  assertEquals "$RESET_COLOR_REMOTE" "\x01\033[0m\x02"
  assertEquals "$RESET_COLOR_CHANGES" "\x01\033[0m\x02"
}

test_no_rcfile_zsh() {
  reset_env_vars
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

set_bash_env_vars() {
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

reset_env_vars() {
  export GIT_RADAR_COLOR_REMOTE_AHEAD=""
  export GIT_RADAR_COLOR_REMOTE_BEHIND=""
  export GIT_RADAR_COLOR_REMOTE_DIVERGED=""
  export GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM=""

  export GIT_RADAR_COLOR_LOCAL_AHEAD=""
  export GIT_RADAR_COLOR_LOCAL_BEHIND=""
  export GIT_RADAR_COLOR_LOCAL_DIVERGED=""

  export GIT_RADAR_COLOR_CHANGES_STAGED=""
  export GIT_RADAR_COLOR_CHANGES_UNSTAGED=""
  export GIT_RADAR_COLOR_CHANGES_CONFLICTED=""
  export GIT_RADAR_COLOR_CHANGES_UNTRACKED=""

  export GIT_RADAR_COLOR_LOCAL_RESET=""
  export GIT_RADAR_COLOR_REMOTE_RESET=""
  export GIT_RADAR_COLOR_CHANGES_RESET=""
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

create_rc_file() {
  echo 'GIT_RADAR_COLOR_REMOTE_AHEAD="remote-ahead"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_REMOTE_BEHIND="remote-behind"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_REMOTE_DIVERGED="remote-diverged"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM="not-upstream"' >> .gitradarrc

  echo 'GIT_RADAR_COLOR_LOCAL_AHEAD="local-ahead"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_LOCAL_BEHIND="local-behind"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_LOCAL_DIVERGED="local-diverged"' >> .gitradarrc

  echo 'GIT_RADAR_COLOR_CHANGES_STAGED="changes-staged"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_CHANGES_UNSTAGED="changes-unstaged"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_CHANGES_CONFLICTED="changes-conflicted"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_CHANGES_UNTRACKED="changes-untracked"' >> .gitradarrc

  echo 'GIT_RADAR_COLOR_LOCAL_RESET="local-reset"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_REMOTE_RESET="remote-reset"' >> .gitradarrc
  echo 'GIT_RADAR_COLOR_CHANGES_RESET="change-reset"' >> .gitradarrc
}

test_with_rcfile_bash() {
  reset_env_vars
  cd_to_tmp

  rcfile_path="$(pwd)"

  create_rc_file
  prepare_bash_colors

  assertEquals "$COLOR_REMOTE_AHEAD" "\x01remote-ahead\x02"
  assertEquals "$COLOR_REMOTE_BEHIND" "\x01remote-behind\x02"
  assertEquals "$COLOR_REMOTE_DIVERGED" "\x01remote-diverged\x02"
  assertEquals "$COLOR_REMOTE_NOT_UPSTREAM" "\x01not-upstream\x02"

  assertEquals "$COLOR_LOCAL_AHEAD" "\x01local-ahead\x02"
  assertEquals "$COLOR_LOCAL_BEHIND" "\x01local-behind\x02"
  assertEquals "$COLOR_LOCAL_DIVERGED" "\x01local-diverged\x02"

  assertEquals "$COLOR_CHANGES_STAGED" "\x01changes-staged\x02"
  assertEquals "$COLOR_CHANGES_UNSTAGED" "\x01changes-unstaged\x02"
  assertEquals "$COLOR_CHANGES_CONFLICTED" "\x01changes-conflicted\x02"
  assertEquals "$COLOR_CHANGES_UNTRACKED" "\x01changes-untracked\x02"

  assertEquals "$RESET_COLOR_LOCAL" "\x01local-reset\x02"
  assertEquals "$RESET_COLOR_REMOTE" "\x01remote-reset\x02"
  assertEquals "$RESET_COLOR_CHANGES" "\x01change-reset\x02"

  rm_tmp
}

test_with_rcfile_zsh() {
  reset_env_vars
  cd_to_tmp

  rcfile_path="$(pwd)"

  create_rc_file
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

  rm_tmp
}

test_with_env_vars_bash() {
  reset_env_vars
  set_bash_env_vars
  prepare_bash_colors

  assertEquals "$COLOR_REMOTE_AHEAD" "\x01remote-ahead\x02"
  assertEquals "$COLOR_REMOTE_BEHIND" "\x01remote-behind\x02"
  assertEquals "$COLOR_REMOTE_DIVERGED" "\x01remote-diverged\x02"
  assertEquals "$COLOR_REMOTE_NOT_UPSTREAM" "\x01not-upstream\x02"

  assertEquals "$COLOR_LOCAL_AHEAD" "\x01local-ahead\x02"
  assertEquals "$COLOR_LOCAL_BEHIND" "\x01local-behind\x02"
  assertEquals "$COLOR_LOCAL_DIVERGED" "\x01local-diverged\x02"

  assertEquals "$COLOR_CHANGES_STAGED" "\x01changes-staged\x02"
  assertEquals "$COLOR_CHANGES_UNSTAGED" "\x01changes-unstaged\x02"
  assertEquals "$COLOR_CHANGES_CONFLICTED" "\x01changes-conflicted\x02"
  assertEquals "$COLOR_CHANGES_UNTRACKED" "\x01changes-untracked\x02"

  assertEquals "$RESET_COLOR_LOCAL" "\x01local-reset\x02"
  assertEquals "$RESET_COLOR_REMOTE" "\x01remote-reset\x02"
  assertEquals "$RESET_COLOR_CHANGES" "\x01change-reset\x02"
}

test_with_env_vars_zsh() {
  reset_env_vars
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

test_bash_colors_local() {
  reset_env_vars
  set_bash_env_vars
  prepare_bash_colors

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

  printf -v expected " 1\x01local-ahead\x02↑\x01local-reset\x02"
  assertEquals "$expected" "$(bash_color_local_commits)"

  git push --quiet >/dev/null
  git reset --hard head^ --quiet >/dev/null

  printf -v expected " 1\x01local-behind\x02↓\x01local-reset\x02"
  assertEquals "$expected" "$(bash_color_local_commits)"

  echo "foo" > foo
  git add .
  git commit -m "new commit" --quiet

  printf -v expected " 1\x01local-diverged\x02⇵\x01local-reset\x021"
  assertEquals "$expected" "$(bash_color_local_commits)"

  rm_tmp
}

test_zsh_colors_local() {
  reset_env_vars
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

test_bash_colors_remote() {
  reset_env_vars
  set_bash_env_vars
  prepare_bash_colors

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

  printf -v expected "$m 1 \x01remote-behind\x02→\x01remote-reset\x02 "
  assertEquals "$expected" "$(bash_color_remote_commits)"

  echo "bar" > bar
  git add .
  git commit -m "new commit" --quiet
  git push --quiet >/dev/null

  printf -v expected "$m 1 \x01remote-diverged\x02⇄\x01remote-reset\x02 1 "
  assertEquals "$expected" "$(bash_color_remote_commits)"

  git pull origin master --quiet >/dev/null
  git push --quiet >/dev/null

  printf -v expected "$m \x01remote-ahead\x02←\x01remote-reset\x02 2 "
  assertEquals "$expected" "$(bash_color_remote_commits)"

  rm_tmp
}

test_zsh_colors_remote() {
  reset_env_vars
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

test_bash_colors_changes() {
  reset_env_vars
  set_bash_env_vars
  prepare_bash_colors

  cd_to_tmp
  git init --quiet

  touch foo
  touch bar
  git add bar
  echo "bar" > bar
  untracked="1\x01changes-untracked\x02A\x01change-reset\x02"
  unstaged="1\x01changes-unstaged\x02M\x01change-reset\x02"
  staged="1\x01changes-staged\x02A\x01change-reset\x02"

  printf -v expected " $staged $unstaged $untracked"
  assertEquals "$expected" "$(bash_color_changes_status)"
  rm_tmp
}

test_zsh_colors_changes() {
  reset_env_vars
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
  rm_tmp
}

. ./shunit/shunit2
