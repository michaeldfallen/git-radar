scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/git-base.sh"

tmpfile=""

cd_to_tmp() {
  tmpfile="/tmp/git-prompt-tests-$(time_now)"
  mkdir -p "$tmpfile"
  cd "$tmpfile"
}

rm_tmp() {
  cd $scriptDir
  rm -r "$tmpfile"
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

. ./shunit/shunit2
