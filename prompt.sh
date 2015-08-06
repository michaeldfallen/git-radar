source ./git-base.sh

local_ahead="$(commits_ahead_of_remote)"
ahead_arrow="↑"

if [[ ("$local_ahead" -gt 0) ]]; then
  local_ahead=" ${local_ahead}${ahead_arrow}"
else
  local_ahead=""
fi

local_behind="$(commits_behind_of_remote)"
behind_arrow="↓"

if [[ "$local_behind" -gt "0" ]]; then
  local_behind=" ${local_behind}${behind_arrow}"
else
  local_behind=""
fi

prompt="$(branch_name)$local_behind$local_ahead $(bash_color_changes_status)"

echo $prompt
