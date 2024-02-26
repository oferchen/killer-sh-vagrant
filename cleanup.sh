#!/bin/bash
set -euo pipefail

destroy_all_vagrant_environments() {
  echo "Destroying all Vagrant environments..."
  vagrant destroy -f
}

destroy_all_vagrant_environments

