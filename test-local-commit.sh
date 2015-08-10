scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/git-base.sh"

tmpfile=""

cd_to_tmp() {
  tmpfile="/tmp/git-prompt-tests-$(time_now)$1"
  mkdir -p "$tmpfile"
  cd "$tmpfile"
}

rm_tmp() {
  cd $scriptDir
  rm -rf /tmp/git-prompt-tests*
}

test_zsh_and_bash_local_commits() {
  local zsh_up="%{[green]%}↑%{%}"
  local zsh_both="%{[yellow]%}⇵%{%}"
  local zsh_down="%{[red]%}↓%{%}"

  printf -v bash_up '\033[1;32m↑\033[0m'
  printf -v bash_both '\033[1;33m⇵\033[0m'
  printf -v bash_down '\033[1;31m↓\033[0m'

  cd_to_tmp "remote"

  assertEquals "" "$(zsh_color_local_commits)"
  assertEquals "" "$(bash_color_local_commits)"

  git init --quiet
  touch README
  git add .
  git commit -m "initial commit" --quiet
  remote="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $remote
  git fetch origin --quiet
  git checkout master --quiet
  repo="$(pwd)"

  assertEquals "" "$(zsh_color_local_commits)"
  assertEquals "" "$(bash_color_local_commits)"

  cd "$repo"
  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet

  assertEquals " 1$zsh_up" "$(zsh_color_local_commits)"
  assertEquals " 1$bash_up" "$(bash_color_local_commits)"

  cd "$remote"
  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet

  cd "$repo"
  git fetch origin --quiet

  assertEquals " 1${zsh_both}1" "$(zsh_color_local_commits)"
  assertEquals " 1${bash_both}1" "$(bash_color_local_commits)"

  git reset --hard HEAD^ --quiet

  assertEquals " 1$zsh_down" "$(zsh_color_local_commits)"
  assertEquals " 1$bash_down" "$(bash_color_local_commits)"
}

. ./shunit/shunit2
