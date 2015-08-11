dot="$(cd "$(dirname "$0")"; pwd)"
source "$dot/git-base.sh"

prompt="$(bash_color_remote_commits)$(branch_name)$(bash_color_local_commits)$(bash_color_changes_status)"

echo $prompt
