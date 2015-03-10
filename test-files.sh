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

test_untracked_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(untracked_status)"

  touch foo
  assertEquals "1$untracked$added" "$(untracked_status)"

  git add .
  assertEquals "" "$(untracked_status)"

  rm_tmp
}

test_unstaged_modified_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(unstaged_status)"

  touch foo
  touch bar
  git add .
  git commit -m "foo and bar" >/dev/null

  echo "foo" >> foo
  assertEquals "1$unstaged$modified" "$(unstaged_status)"

  echo "bar" >> bar
  assertEquals "2$unstaged$modified" "$(unstaged_status)"

  rm_tmp
}

test_unstaged_deleted_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(unstaged_status)"

  touch foo
  touch bar
  git add .
  git commit -m "foo and bar" >/dev/null

  rm foo
  assertEquals "1$unstaged$deleted" "$(unstaged_status)"

  rm bar
  assertEquals "2$unstaged$deleted" "$(unstaged_status)"

  rm_tmp
}

test_staged_added_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(staged_status)"

  touch foo
  git add .
  assertEquals "1$staged$added" "$(staged_status)"

  touch bar
  git add .
  assertEquals "2$staged$added" "$(staged_status)"

  rm_tmp
}

test_staged_modified_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(staged_status)"

  touch foo
  touch bar
  git add .
  git commit -m "foo and bar" >/dev/null

  echo "foo" >> foo
  git add .
  assertEquals "1$staged$modified" "$(staged_status)"

  echo "bar" >> bar
  git add .
  assertEquals "2$staged$modified" "$(staged_status)"

  rm_tmp
}

test_staged_deleted_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(staged_status)"

  touch foo
  touch bar
  git add .
  git commit -m "foo and bar" >/dev/null

  rm foo
  git add .
  assertEquals "1$staged$deleted" "$(staged_status)"

  rm bar
  git add .
  assertEquals "2$staged$deleted" "$(staged_status)"

  rm_tmp
}

test_staged_renamed_files() {
  cd_to_tmp
  git init --quiet

  assertEquals "" "$(staged_status)"

  touch foo
  touch bar
  git add .
  git commit -m "foo and bar" >/dev/null

  mv foo foo2
  git add .
  assertEquals "1$staged$renamed" "$(staged_status)"

  mv bar bar2
  git add .
  assertEquals "2$staged$renamed" "$(staged_status)"

  rm_tmp
}

test_conflicted_both_changes() {
  cd_to_tmp
  git init --quiet

  git checkout -b foo --quiet
  echo "foo" >> foo
  git add .
  git commit -m "foo" --quiet

  git checkout -b foo2 --quiet
  echo "bar" >> foo
  git add .
  git commit -m "bar" --quiet

  git checkout foo --quiet
  echo "foo2" >> foo
  git add .
  git commit -m "foo2" --quiet

  assertEquals "" "$(conflicted_status)"

  git merge foo2 >/dev/null

  assertEquals "1$conflicted$both" "$(conflicted_status)"

  rm_tmp
}

test_conflicted_them_changes() {
  cd_to_tmp
  git init --quiet

  git checkout -b foo --quiet
  echo "foo" >> foo
  git add .
  git commit -m "foo" --quiet

  git checkout -b foo2 --quiet
  rm foo
  git add .
  git commit -m "delete foo" --quiet

  git checkout foo --quiet
  echo "foo2" >> foo
  git add .
  git commit -m "foo2" --quiet

  assertEquals "" "$(conflicted_status)"

  git merge foo2 >/dev/null

  assertEquals "1$conflicted$them" "$(conflicted_status)"

  rm_tmp
}

test_conflicted_us_changes() {
  cd_to_tmp
  git init --quiet

  git checkout -b foo --quiet
  echo "foo" >> foo
  git add .
  git commit -m "foo" --quiet

  git checkout -b foo2 --quiet
  echo "bar" >> foo
  git add .
  git commit -m "bar" --quiet

  git checkout foo --quiet
  rm foo
  git add .
  git commit -m "delete foo" --quiet

  assertEquals "" "$(conflicted_status)"

  git merge foo2 >/dev/null

  assertEquals "1$conflicted$us" "$(conflicted_status)"

  rm_tmp
}

test_is_dirty() {
  cd_to_tmp

  assertFalse "not in repo" is_dirty

  git init --quiet
  assertFalse "in repo and clean" is_dirty

  touch foo
  assertTrue "untracked files" is_dirty

  git add .
  assertTrue "staged addition files" is_dirty

  git commit -m "inital commit" --quiet

  assertFalse "commited and clean" is_dirty

  echo "foo" >> foo
  assertTrue "modified file unstaged" is_dirty

  git add .
  assertTrue "modified file staged" is_dirty

  rm_tmp
}

. ./shunit/shunit2
