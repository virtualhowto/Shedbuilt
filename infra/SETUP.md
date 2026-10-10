# Shedbuilt deployment entry point

**Approved site:** `shedbuilt.virtualhowto.com`.

The only deployable candidate in this source version is the **private engineering preview**. Follow [`../docs/GO-LIVE.md`](../docs/GO-LIVE.md). This requires a functioning Authentik forward-auth middleware attached to your Swarm Traefik service before anyone receives the website URL.

- `Dockerfile.preview` serves the runnable standalone physics lab.
- `stack.preview.yml` serves it only through your TLS-enabled Traefik and explicitly requires `SHEDBUILT_AUTH_MIDDLEWARE`.
- `preflight-preview.sh` checks domain, overlay, middleware reference, manager and immutable image digest. It cannot verify that Authentik is actually authenticating users: perform the manual acceptance checks.
- `deploy-preview.sh` deploys one preview replica after preflight.
- GitHub workflows `build-preview.yml` and `deploy-preview.yml` build and promote only the preview image; deployment requires the protected `production` environment.

The Godot server project is not yet a production multiplayer service. `deploy.sh` is deliberately disabled, and the old multiplayer workflow has been relocated to `docs/examples/deploy-multiplayer-FUTURE.yml` so it cannot be triggered accidentally.

No DNS, GitHub repo, Swarm node, Traefik middleware, runner, or production service is automatically created by the provided source files.
