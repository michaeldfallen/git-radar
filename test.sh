set -e

scriptDir="$( dirname "$0" )"

source "$scriptDir/git-base.sh"

echo "\n---------------------------"
echo "\n In a git repo"
echo "\n---------------------------"

echo "\nTest: Root of this git repo"
echo "$(git_root)"

echo "\nTest: Location of .git"
echo "$(dot_git)"

echo "\nTest: is_repo should be false"
if is_repo; then
  echo "is repo"
else
  echo "not repo"
fi

echo "\nTest: Record the timestamp"
record_timestamp
echo "Timestamp = $(timestamp)"
echo "Time now = $(time_now)"

echo "\nTest: Time to update when just recorded"
if time_to_update; then
  echo "time to update"
else
  echo "not time yet"
fi

echo "\nTest: Don't fetch if it's not time to update"
fetch_async "debug"

echo "\nTest: Time to update when timestamp 5 mins ago"
touch -A "-010000" "$(dot_git)/lastupdatetime"
if time_to_update; then
  echo "time to update"
else
  echo "not time yet"
fi

echo "\nTest: Do a non-blocking git fetch"
fetch_async "debug"
echo "Did I block?"


echo "\n---------------------------"
echo "\n Not in a git repo"
echo "\n---------------------------"

mkdir -p /tmp/git-base-tests
cd /tmp/git-base-tests

echo "\nTest: Root of this git repo"
echo "git_root is:$(git_root) (empty means no root)"

echo "\nTest: Location of .git"
echo "dot_git is:$(dot_git) (empty means no root)"

echo "\nTest: is_repo should be false"
if is_repo; then
  echo "is repo"
else
  echo "not repo"
fi

echo "\nTest: Record the timestamp"
record_timestamp
echo "no output should be seen"

echo "\nTest: Check the timestamp"
echo "timestamp is:$(timestamp) (empty means not in dir)"

echo "\nTest: Is it time to update?"
if time_to_update; then
  echo "time to update"
else
  echo "not time yet"
fi

echo "\nTest: Try to fetch"
fetch_async "debug"
