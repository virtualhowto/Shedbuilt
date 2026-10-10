#!/usr/bin/env bash
set -euo pipefail
echo 'BLOCKED: Multiplayer service is an incomplete development skeleton; do not deploy.' >&2
echo 'To launch the private engineering lab, use: bash infra/deploy-preview.sh' >&2
exit 78
