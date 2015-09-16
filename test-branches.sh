scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/radar-base.sh"

tmpfile=""

cd_to_tmp() {
  tmpfile="/tmp/git-prompt-tests-$(time_now)"
  mkdir -p "$tmpfile"
  cd "$tmpfile"
}

rm_tmp() {
  cd $scriptDir
  rm -rf /tmp/git-prompt-tests*
}

test_branch_name_in_repo() {
  cd_to_tmp
  git init --quiet
  git checkout -b foo --quiet
  assertEquals "foo" "$(branch_name)"

  git checkout -b bar --quiet
  assertEquals "bar" "$(branch_name)"

  git checkout -b baz --quiet
  assertEquals "baz" "$(branch_name)"

  rm_tmp
}

test_branch_name_not_in_repo() {
  cd_to_tmp
  assertEquals "" "$(branch_name)"
  rm_tmp
}

test_detached_from_branch() {
  cd_to_tmp
  git init --quiet
  assertEquals "master" "$(branch_name)"

  touch README
  git add .
  git commit -m "initial commit" --quiet

  touch foo
  git add .
  git commit -m "foo" --quiet

  git checkout --quiet HEAD^ >/dev/null
  sha="$(commit_short_sha)"

  assertNotEquals "master" "$(branch_name)"
  assertEquals "$sha" "$(branch_ref)"
  assertEquals "detached@$sha" "$(zsh_readable_branch_name)"
  assertEquals "detached@$sha" "$(bash_readable_branch_name)"
  assertEquals "detached@$sha" "$(readable_branch_name)"

  rm_tmp
}

test_branch_name_returns_error() {
  cd_to_tmp
  git init --quiet

  touch README
  git add .
  git commit -m "initial commit" --quiet

  touch foo
  git add .
  git commit -m "foo" --quiet

  git checkout --quiet HEAD^ >/dev/null

  retcode="$(branch_name; echo $?)"
  assertEquals "1" "$retcode"
  rm_tmp
}

test_remote_branch_name_quiet_when_not_in_repo() {
  cd_to_tmp

  debug_output="$(
    {
    output="$(
      remote_branch_name;
    )"
    } 2>&1
    echo "$output"
  )"

  usages="$(echo "$debug_output" | grep -E "(usage|fatal):" | wc -l)"

  echo "$debug_output"

  assertEquals "       0" "$usages"

  rm_tmp
}

. ./shunit/shunit2
