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
  printf "\t\tCount\tMean\tMedian\tMin\tMax\n"
}

profile () {
  cmd="$2"
  printf '%s\t' $1
  for (( i = 0; i < 100; i++ )); do
    start=$(gdate +%s.%N)
    eval $cmd > /dev/null
    duration=$(echo "$(gdate +%s.%N) - $start" | bc)
    timings[$i]=$duration
  done
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
