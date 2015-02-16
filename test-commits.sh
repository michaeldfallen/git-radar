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

test_commits_with_no_commits() {
  cd_to_tmp
  git init --quiet

  assertEquals "0" "$(commits_ahead_of_remote)"
  assertEquals "0" "$(commits_behind_of_remote)"

  rm_tmp
}

test_commits_behind_no_remote() {
  cd_to_tmp
  git init --quiet

  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  assertEquals "0" "$(commits_behind_of_remote)"

  rm_tmp
}

test_commits_ahead_no_remote() {
  cd_to_tmp
  git init --quiet

  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  assertEquals "0" "$(commits_ahead_of_remote)"

  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet
  assertEquals "0" "$(commits_ahead_of_remote)"

  rm_tmp
}

test_commits_ahead_with_remote() {
  cd_to_tmp "remote"
  git init --quiet
  touch README
  git add .
  git commit -m "initial commit" --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout master --quiet
  repoLocation="$(pwd)"

  cd "$remoteLocation"
  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  cd "$repoLocation"
  git fetch origin --quiet
  assertEquals "1" "$(commits_ahead_of_remote)"

  cd "$remoteLocation"
  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet
  cd "$repoLocation"
  git fetch origin --quiet
  assertEquals "2" "$(commits_ahead_of_remote)"

  rm_tmp
}

test_commits_ahead_with_remote() {
  cd_to_tmp "remote"
  git init --quiet
  touch README
  git add .
  git commit -m "initial commit" --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout master --quiet

  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  assertEquals "1" "$(commits_ahead_of_remote)"

  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet
  assertEquals "2" "$(commits_ahead_of_remote)"

  rm_tmp
}

test_remote_ahead_master() {
  cd_to_tmp "remote"
  git init --quiet
  touch README
  git add .
  git commit -m "initial commit" --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout master --quiet

  git checkout -b foo --quiet
  git push --quiet -u origin foo >/dev/null

  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  assertEquals "0" "$(remote_ahead_of_master)"
  git push --quiet
  assertEquals "1" "$(remote_ahead_of_master)"

  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet
  assertEquals "1" "$(remote_ahead_of_master)"
  git push --quiet
  assertEquals "2" "$(remote_ahead_of_master)"

  rm_tmp
}

test_remote_behind_master() {
  cd_to_tmp "remote"
  git init --bare --quiet
  remoteLocation="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $remoteLocation
  git fetch origin --quiet
  git checkout -b master --quiet
  touch README
  git add README
  git commit -m "initial commit" --quiet
  
  git push --quiet -u origin master >/dev/null 
  git reset --quiet --hard HEAD

  git checkout -b foo --quiet
  git push --quiet -u origin foo >/dev/null

  assertEquals "0" "$(remote_behind_of_master)"
  git checkout master --quiet
  echo "foo" > foo
  git add .
  git commit -m "test commit" --quiet
  git push --quiet >/dev/null
  git checkout foo --quiet
  assertEquals "1" "$(remote_behind_of_master)"

  git checkout master --quiet
  echo "bar" > bar
  git add .
  git commit -m "test commit" --quiet
  git push --quiet >/dev/null
  git checkout foo --quiet
  assertEquals "2" "$(remote_behind_of_master)"

  rm_tmp
}

. ./shunit/shunit2
