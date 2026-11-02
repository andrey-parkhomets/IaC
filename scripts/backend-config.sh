#!/usr/bin/env bash
# Writes backend.hcl for every environment created by a bootstrap root.
# "bootstrap" goes into the bootstrap dir itself, everything else into tf/<env>/.
# Usage: scripts/backend-config.sh tf/bootstrap/<subscription>
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
bootstrap_dir=$(cd "${1:?usage: $0 <bootstrap dir>}" && pwd)

config=$(terraform -chdir="$bootstrap_dir" output -json backend_config)

for env in $(jq -r 'keys[]' <<<"$config"); do
  if [[ $env == bootstrap ]]; then
    target=$bootstrap_dir
  else
    target=$repo_root/tf/$env
  fi
  mkdir -p "$target"
  jq -r --arg env "$env" '.[$env] | to_entries[] | "\(.key) = \(.value | tojson)"' <<<"$config" >"$target/backend.hcl"
  echo "wrote $target/backend.hcl"
done
