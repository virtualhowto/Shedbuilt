# Shedbuilt: private preview go-live runbook

**Approved domain:** `shedbuilt.virtualhowto.com`.

## What is safe to deploy now

Only the standalone **browser engineering preview** (`infra/stack.preview.yml`) after configuring and verifying Authentik forward-auth. The full Godot game-server stack (`infra/stack.yml`) remains **blocked** pending proper short-lived lobby invites, authorization, session management, validation, and browser/server multiplayer tests.

## Step 1 — Make the private GitHub repository

On Windows, extract the ZIP and run in PowerShell from the `Shedbuilt` directory:

```powershell
gh auth login
./scripts/publish-github.ps1
```

The script initializes Git if necessary, commits source, and creates or connects to the **private** repository. Alternatively from an existing committed Git checkout use `gh repo create virtualhowto/Shedbuilt --private --source=. --remote=origin --push`.

If a repository has already been created in the browser, substitute:

```bash
git remote add origin git@github.com:virtualhowto/Shedbuilt.git
git push -u origin main
```

Never make this repo public until the proprietary licence, assets and security model are ready.

## Step 2 — Secure the edge

- Create DNS record for `shedbuilt.virtualhowto.com` pointing at the existing Traefik endpoint (a proxied Cloudflare setup needs compatible TLS/proxy settings).
- Create an Authentik Application/Provider that only permits approved accounts to access the Shedbuilt preview; enable MFA for administrators.
- Configure an **existing Traefik forward-auth middleware** attached to that provider, for example `authentik@file`. This value is an EXAMPLE; set the real middleware name in GitHub repository variable `SHEDBUILT_AUTH_MIDDLEWARE`.
- Confirm unauthenticated requests are redirected or denied by Authentik, including `/version.json` and `/healthz`. Authentik gate is required, not optional.
- Ensure the Traefik `websecure` entry point has a working certificate for this host. Restrict direct access to container ports.

## Step 3 — Build the preview image

- Enable GitHub Actions and `packages:write` permissions for `build-preview.yml`.
- On push to `main`, workflow `Build private engineering preview` runs tests and publishes `ghcr.io/virtualhowto/shedbuilt-preview` with the exact commit SHA.
- Copy the **immutable** `image@sha256:...` from the build summary. A tag alone will be rejected by preflight.
- Grant the Swarm node read access to the private GHCR package; `docker login ghcr.io` with a scoped token if needed. Never store credentials in the repository.

## Step 4 — Approve the deploy

- Label the dedicated runner `shedbuilt-deployer`; run it on a **trusted Swarm manager** (do not let untrusted PR jobs run there).
- Create GitHub `production` Environment with required reviewers.
- Configure repo variable `TRAEFIK_NETWORK` with the real existing *overlay* name and `SHEDBUILT_AUTH_MIDDLEWARE` with the working forward-auth middleware name.
- Run `Deploy approved private preview` workflow with the exact image digest from the build job.
- Alternatively, from the Swarm manager: set the four environment variables as in `.env.example`, run `bash infra/preflight-preview.sh`, then `bash infra/deploy-preview.sh`.

## Step 5 — Manual acceptance after deploy

1. Unauthenticated browser should show Authentik login, not the game.
2. An approved account should reach the physics lab at `https://shedbuilt.virtualhowto.com`.
3. Reject an unapproved account and verify the domain is HTTPS, with no mixed-content warnings.
4. Authenticated `https://shedbuilt.virtualhowto.com/version.json` must show the deployed commit SHA.
5. Confirm `/healthz`, container health, Traefik route, and Swarm status.
6. Confirm **no** game-server WSS or debug ports are Internet-accessible.
7. Record package digest and deploy SHA for rollback.

## Next engineering phase

Implement real modular rigid-body wheels, connections with server-measured loads, server-authoritative assembly transactions, secure short-lived invite tickets, synchronized multiplayer, reconnect handling, complete round flow and benchmarking under 4 concurrent players. Treat current joint-strength lab as an illustrative engineering model rather than a validated high-fidelity simulator.

## Notes

- A Traefik middleware reference is only configuration; it does not prove the Authentik integration is valid. Verify on the live endpoint before inviting players.
- CI package publishing requires a private GitHub repository; no repository or DNS changes were made on the user's behalf by this artifact.
- Nothing in this runbook grants permission to expose the unfinished multiplayer server publicly.
