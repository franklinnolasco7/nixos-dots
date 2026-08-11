#!/usr/bin/env bash
# Aspire 7 installer — thin wrapper around the generic installer.
set -euo pipefail

exec bash "$(dirname "$0")/install.sh" aspire7 "$@"
