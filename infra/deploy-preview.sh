#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/preflight-preview.sh"
docker stack deploy --with-registry-auth --resolve-image always -c "$DIR/stack.preview.yml" shedbuilt-preview
docker stack services shedbuilt-preview
printf '\nExpected: https://%s (private Authentik login only).\n' "$SHEDBUILT_DOMAIN"
echo 'REQUIRED manual acceptance: unauthenticated redirect; authenticated lab; /version.json commit; TLS certificate; server never exposed.'
