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

  assertEquals "0" "$(untracked_files)"
  
  touch foo
  assertEquals "1" "$(untracked_files)"

  git add .
  assertEquals "0" "$(untracked_files)"

  rm_tmp
}

. ./shunit/shunit2
