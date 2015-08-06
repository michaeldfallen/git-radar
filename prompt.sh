source ./git-base.sh

prompt="$(branch_name)$(bash_color_local_commits)$(bash_color_changes_status)"

echo $prompt
