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

report() {
  arr=( "$@" )
  printf '%s\n' "${arr[@]}" | sort -n | awk '
  function colored(s) {
    OFMT="%2.3fs";
    OFS="";
    ORS="";
    if( s > 0.2 ) {
      print "\033[1;31m", s, "\033[0m"
    } else if( s > 0.1 ) {
      print "\033[1;33m", s, "\033[0m"
    } else {
      print "\033[1;32m", s, "\033[0m"
    }
    OFS="\t";
    ORS="\n";
  }
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    min = a[0] + 0;
    max = a[c-1] + 0;
    ave = sum / c;
    if( (c % 2) == 1 ) {
      median = a[ int(c/2) ];
    } else {
      median = ( a[c/2] + a[c/2-1] ) / 2;
    }
    OFS="\t";
    OFMT="%2.3fs";
    print c, colored(ave), colored(median), colored(min), colored(max);
  }
'
}

table_headers() {
  printf "                         Count\tMean\tMedian\tMin\tMax\n"
}

profile () {
  cmd="$2"
  for (( i = 0; i < 100; i++ )); do
    start=$(gdate +%s.%N)
    eval $cmd > /dev/null
    duration=$(echo "$(gdate +%s.%N) - $start" | bc)
    timings[$i]=$duration
  done
  printf '%-25s' "$1"
  report "${timings[@]}"
}

test_empty_repo() {
  cd_to_tmp
  git init --quiet

  table_headers
  profile "prompt.zsh" "/.$scriptDir/prompt.zsh"
  profile "prompt.bash" "/.$scriptDir/prompt.bash"

  rm_tmp
}

test_lots_of_file_changes() {
  cd_to_tmp
  git init --quiet

  table_headers

  profile "no changes zsh" "/.$scriptDir/prompt.zsh"
  profile "no changes bash" "/.$scriptDir/prompt.bash"

  for (( i = 0; i < 100; i++ )); do
    touch foo$i
  done

  profile "100 untracked zsh" "/.$scriptDir/prompt.zsh"
  profile "100 untracked bash" "/.$scriptDir/prompt.bash"

  for (( i = 0; i < 100; i++ )); do
    touch bar$i
    git add bar$i
  done

  profile "100 added zsh" "/.$scriptDir/prompt.zsh"
  profile "100 added bash" "/.$scriptDir/prompt.bash"

  for (( i = 0; i < 100; i++ )); do
    echo "bar$i" > bar$i
  done

  profile "100 modify zsh" "/.$scriptDir/prompt.zsh"
  profile "100 modify bash" "/.$scriptDir/prompt.bash"

  rm_tmp
}

test_commits_local_and_remote_ahead() {
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

  table_headers

  profile "0 commits zsh" "/.$scriptDir/prompt.zsh"
  profile "0 commits bash" "/.$scriptDir/prompt.bash"

  for (( i = 0; i < 100; i++ )); do
    echo "foo$i" >> foo
    git add .
    git commit -m "foo $i" --quiet
  done

  profile "100 local zsh" "/.$scriptDir/prompt.zsh"
  profile "100 local bash" "/.$scriptDir/prompt.bash"

  git push --quiet

  profile "100 remote zsh" "/.$scriptDir/prompt.zsh"
  profile "100 remote bash" "/.$scriptDir/prompt.bash"

  rm_tmp
}

test_commits_local_and_remote_behind() {
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

  git checkout master --quiet

  table_headers

  profile "0 commits zsh" "/.$scriptDir/prompt.zsh"
  profile "0 commits bash" "/.$scriptDir/prompt.bash"

  for (( i = 0; i < 100; i++ )); do
    echo "foo$i" >> foo
    git add .
    git commit -m "foo $i" --quiet
  done

  git push --quiet
  git checkout foo --quiet

  profile "100 behind remote zsh" "/.$scriptDir/prompt.zsh"
  profile "100 behind remote bash" "/.$scriptDir/prompt.bash"

  git checkout master --quiet
  git checkout -b bar --quiet
  git push --quiet -u origin bar >/dev/null
  git reset --hard origin/foo --quiet

  profile "100 behind mine zsh" "/.$scriptDir/prompt.zsh"
  profile "100 behind mine bash" "/.$scriptDir/prompt.bash"

}

test_large_repo() {
  cd_to_tmp
  git clone https://github.com/Homebrew/homebrew --quiet
  cd homebrew

  table_headers
  profile "prompt.zsh" "/.$scriptDir/prompt.zsh"
  profile "prompt.bash" "/.$scriptDir/prompt.bash"

  rm_tmp
}

test_lots_of_submodules() {
  cd_to_tmp
  git clone https://github.com/michaeldfallen/dotfiles --quiet
  cd dotfiles
  git submodule update --init --quiet

  table_headers
  profile "prompt.zsh" "/.$scriptDir/prompt.zsh"
  profile "prompt.bash" "/.$scriptDir/prompt.bash"

  rm_tmp
}

. ./shunit/shunit2
