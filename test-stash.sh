#!/bin/bash
scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/radar-base.sh"

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

test_unstashed_status() {
  cd_to_tmp
  git init --quiet

  assertEquals "0" "$(stashed_status)"

  rm_tmp
}

test_stashed_status() {
  cd_to_tmp
  git init --quiet

  touch foo
  git add --all
  git commit -m "Initial commit"  >/dev/null
  echo "test">foo
  git stash > /dev/null
  assertEquals "1" "$(stashed_status)"
  
  echo "test2">foo
  git stash > /dev/null
  assertEquals "2" "$(stashed_status)"

  git stash drop > /dev/null
  assertEquals "1" "$(stashed_status)"


  rm_tmp
}

. ./shunit/shunit2
