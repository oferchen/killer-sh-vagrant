#!/bin/bash
set -euo pipefail

get_join_command() {
  local join_command
  join_command=$(vagrant ssh cks-master --command 'sudo kubeadm token create --print-join-command --ttl 0' 2>/dev/null | grep -v -i warning)
  echo "${join_command}" | sed 's/[[:space:]]*$//'
}

join_cluster() {
  local join_command="$1"
  vagrant ssh cks-worker --command "sudo ${join_command}"
}

join_command=$(get_join_command)
join_cluster "${join_command}"

