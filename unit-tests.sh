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

test_git_root_in_repo() {
  cd $scriptDir
  local root="$(git_root)"
  assertEquals "$scriptDir" "$root"
}

test_git_root_not_in_repo() {
  cd_to_tmp
  local root="$(git_root)"
  assertEquals "" "$root"
  rm_tmp
}

test_dot_git_location_not_in_repo() {
  cd_to_tmp
  local filePath="$(dot_git)"
  assertEquals "" "$filePath"
  rm_tmp
}

test_dot_git_location_in_repo() {
  cd $scriptDir
  local filePath="$(dot_git)"
  local expected=".git"
  assertEquals "$expected" "$filePath"
}

test_is_repo_not_in_repo() {
  cd_to_tmp
  assertFalse is_repo
  rm_tmp
}

test_is_repo_in_repo() {
  cd $scriptDir
  assertTrue is_repo
}

test_record_timestamp_in_repo() {
  cd $scriptDir
  record_timestamp
  local timestamp="$(timestamp)"
  local timenow="$(time_now)"
  assertSame "$timenow" "$timestamp"
}

test_time_to_update_when_timestamp_is_old() {
  cd $scriptDir
  touch -A "-010000" "$(dot_git)/lastupdatetime"
  assertTrue time_to_update
}

test_not_time_to_update_when_just_recorded() {
  cd $scriptDir
  record_timestamp
  assertFalse time_to_update
}

. ./shunit/shunit2
