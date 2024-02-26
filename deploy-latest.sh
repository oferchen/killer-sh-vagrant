#!/bin/bash
set -euo pipefail

INSTALL_SCRIPT_NAME="latest"
VAGRANT_FILE="Vagrantfile"
JOIN_NODE_SCRIPT="join-node.sh"

start_vagrant() {
  if [ -f "$VAGRANT_FILE" ]; then
    INSTALL_SCRIPT=$INSTALL_SCRIPT_NAME vagrant up
  else
    echo "$VAGRANT_FILE does not exist. Exiting."
    exit 1
  fi
}

join_node() {
  if [ -x "$JOIN_NODE_SCRIPT" ]; then
    ./$JOIN_NODE_SCRIPT
  else
    echo "$JOIN_NODE_SCRIPT does not exist or is not executable. Exiting."
    exit 1
  fi
}

start_vagrant
join_node

