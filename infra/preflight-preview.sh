#!/usr/bin/env bash
set -euo pipefail
: "${SHEDBUILT_DOMAIN:?Missing domain}"
: "${TRAEFIK_NETWORK:?Missing Traefik network}"
: "${SHEDBUILT_AUTH_MIDDLEWARE:?Missing Traefik Authentik middleware}"
: "${SHEDBUILT_PREVIEW_IMAGE:?Missing immutable preview image}"
[[ "$SHEDBUILT_DOMAIN" == "shedbuilt.virtualhowto.com" ]] || { echo 'ERROR: Unexpected hostname' >&2; exit 2; }
[[ "$SHEDBUILT_PREVIEW_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]] || { echo 'ERROR: Preview image must be pinned to a digest' >&2; exit 3; }
[[ "$SHEDBUILT_AUTH_MIDDLEWARE" =~ ^[a-zA-Z0-9_.-]+@(file|docker|swarm)$ ]] || { echo 'ERROR: Auth middleware must specify Traefik provider (e.g. authentik@file)' >&2; exit 4; }
command -v docker >/dev/null
[[ "$(docker info --format '{{.Swarm.ControlAvailable}}')" == true ]] || { echo 'ERROR: Must run from Swarm manager' >&2; exit 5; }
[[ "$(docker network inspect "$TRAEFIK_NETWORK" --format '{{.Driver}}')" == overlay ]] || { echo 'ERROR: Traefik overlay network missing' >&2; exit 6; }
docker node ls --format '{{.Status}} {{.ManagerStatus}}' | grep -q Ready || { echo 'ERROR: No ready Swarm nodes' >&2; exit 7; }
# Middleware existence / Authentik behavior must be verified using HTTP 401/302 and a successful authorized login.
# The existing middleware is intentionally not created or reconfigured automatically.
echo 'PASS: static preview preflight. Must verify actual Authentik redirect and authenticated access.'
