#!/usr/bin/env bash
set -euo pipefail
: "${SHEDBUILT_DOMAIN:?Set verified domain}"
: "${TRAEFIK_NETWORK:?Set existing Traefik overlay network name}"
: "${SHEDBUILT_WEB_IMAGE:?Set tested immutable web image}"
: "${SHEDBUILT_GAME_IMAGE:?Set tested immutable game image}"
for var in SHEDBUILT_WEB_IMAGE SHEDBUILT_GAME_IMAGE; do
  ref="${!var}"
  [[ "$ref" =~ @sha256:[0-9a-f]{64}$ ]] || { echo "ERROR: $var must use immutable SHA256 digest" >&2; exit 2; }
done
[[ "$SHEDBUILT_DOMAIN" =~ ^[a-z0-9.-]+$ ]] || { echo 'ERROR: invalid domain' >&2; exit 3; }
command -v docker >/dev/null
[[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ]] || { echo 'ERROR: Swarm inactive' >&2; exit 4; }
docker network inspect "$TRAEFIK_NETWORK" >/dev/null
[[ "$(docker network inspect "$TRAEFIK_NETWORK" --format '{{.Driver}}')" = overlay ]] || { echo 'ERROR: ingress must be overlay' >&2; exit 5; }
docker secret inspect shedbuilt_lobby_key >/dev/null
docker node ls --format '{{.Hostname}} {{.Status}}' | grep -q ' Ready' || { echo 'ERROR: no ready nodes' >&2; exit 6; }
for ref in "$SHEDBUILT_WEB_IMAGE" "$SHEDBUILT_GAME_IMAGE"; do docker manifest inspect "$ref" >/dev/null; done
# Operator must separately verify node label & TLS reachability, and peer authentication.
echo 'Shedbuilt static Swarm preflight PASS. Live TLS and private-auth smoke checks remain required.'
