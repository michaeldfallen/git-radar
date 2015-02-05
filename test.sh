set -e

scriptDir="$( dirname "$0" )"

source "$scriptDir/git-base.sh"

echo "\nTest: Root of this git repo"
echo "$(git_root)"

echo "\nTest: Location of .git"
echo "$(dot_git)"

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
