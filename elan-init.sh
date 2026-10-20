#!/usr/bin/env bash
set -euo pipefail

# Download official elan installer and run with passed arguments
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- "$@"
