# SHEDBUILT — Build it in the shed. Test it the hard way.

**Status:** v0.1 engineering proof-of-concept / repository scaffold. **Not a released multiplayer game.**

A web-first 3D Australian backyard invention game. Scavenge scrap, assemble a contraption under a configurable timer, choose fastening methods, then test the machine against a challenge. Solo and cooperative play, with private-friends multiplayer planned.

## What's included and what works

- `web-lab/`: a **runnable, dependency-free browser engineering lab** — selectable duct tape/bolts/welds, tool skill, wheel alignment, build budget, simulated hill descent, break/fail readouts. This is deliberately a **2D simplified mechanics lab**, not the finished 3D game.
- `godot/`: Godot **4.6** 3D proof-of-concept — procedural scrapyard hill, sliding prototype chassis with decorative wheel meshes, front axle as a separate rigid body joined with a `PinJoint3D`, switchable camera, build method selection, joint-load model, timed build and release. Godot Web export is the intended 3D client. This code is a starter implementation and requires an actual Godot run to validate.
- `tests/`: deterministic Node.js structural/construction/rolling tests, plus a Godot-side test script; the mathematical layer is intentionally conservative, not FE analysis.
- `infra/`: local browser lab Compose + production-design Swarm stack with Traefik HTTPS/WSS and separated web/game services, immutable image placeholders and preflight checks.
- `.github/workflows/`: Node checks and Godot headless validation/export (requires pinned runner tooling and export templates; see setup).
- `docs/`: implementation specification, architecture, physics and security acceptance plan.

## Try the physics lab now

For **instant, offline browser preview**, open `web-lab/Shedbuilt-lab-standalone.html` in any desktop browser. No server or external libraries are needed.

For the modular source files, a static HTTP server works (ES modules cannot reliably run via `file://`):

```bash
cd web-lab
python3 -m http.server 8080
# visit http://localhost:8080
```

Or Docker: `docker compose -f infra/compose.lab.yml up -d --build`, then http://localhost:8080.

```bash
node --test tests/*.test.mjs
```

## Open the 3D Godot proof of concept

1. Install **Godot 4.6 Standard (not .NET)** plus its matching Web export templates.
2. Import `godot/project.godot` in the editor. Run the main scene. In browser builds use a current desktop browser with WebGL 2.0.
3. CLI validation: `godot --headless --path godot --editor --quit` then `godot --headless --path godot --script res://tests/test_physics.gd`.
4. Export to `build/web/index.html`: `mkdir -p build/web && godot --headless --path godot --export-release Web ../build/web/index.html` (shell path relative to Godot project directory; adjust to absolute path for your environment).
5. Serve the whole `build/web` folder using HTTPS; never open its `index.html` from disk. Game server mode: `godot --headless --path godot -- --server --port=9080`.

**Web-first engine choice:** Godot `gl_compatibility` renderer, GDScript, and explicit **GodotPhysics3D** on browser *and* headless server. Jolt can be reconsidered after cross-platform regression testing; identical physics backend is preferable to optimizing prematurely. Web exports only provide WebSocket/WebRTC networking, not ENet UDP.

## Prototype boundaries

The browser lab and Godot test are separate experiments and are **not synchronized multiplayer clients**. `network/GameNetwork.gd` includes a restricted RPC scaffold; real server-authoritative assembly replication, replay state, private invitations and session orchestration must be completed before enabling public access. Current 3D sample has a simplified chassis/axle, no complete rolling-wheel mechanics, no production vehicle damage telemetry, and no career persistence. See `docs/IMPLEMENTATION.md` and `docs/ROADMAP.md` for staged acceptance criteria.

## Deployment

Production stack requires your own image registry, TLS-enabled Traefik ingress, a dedicated game node, a managed secret for the private lobby, DNS, websocket sticky routing or single replica, and reachable secure WebSocket endpoint. `infra/stack.yml` is a **template**. Images deliberately require an immutable digest; runner does not deploy untested `latest`.

**Confirmed hostname (not yet provisioned):** `shedbuilt.virtualhowto.com`. **Private friends only**; do not expose this early prototype publicly.

## Repo initialization

```bash
git init -b main
git add .
git commit -m "feat: initial Shedbuilt web-first physics laboratory"
git remote add origin git@github.com:virtualhowto/Shedbuilt.git
git push -u origin main
```

Create the **private** GitHub repository first. Neither its creation nor the actual GitHub commit or deployment is implied by this download.

## Licence

No license selected. Repository remains all-rights-reserved pending explicit licensing decision. Replace placeholder art before distribution.

## Preview launch (separate from multiplayer)

Production hostname is **shedbuilt.virtualhowto.com**. See [`docs/GO-LIVE.md`](docs/GO-LIVE.md) for the safe first deployment: GitHub Actions builds a tested GHCR Docker image from the standalone browser lab, and `infra/stack.preview.yml` runs it behind required Authentik/Traefik forward-auth. This deploys the physics preview ONLY and never exposes the unfinished Godot multiplayer network service.

```bash
# On a trusted Docker Swarm manager after setting real values in your shell:
export SHEDBUILT_DOMAIN=shedbuilt.virtualhowto.com
export TRAEFIK_NETWORK=your_existing_traefik_overlay
export SHEDBUILT_AUTH_MIDDLEWARE=your_existing_authentik_middleware@file
export SHEDBUILT_PREVIEW_IMAGE=ghcr.io/virtualhowto/shedbuilt-preview@sha256:PASTE_REAL_DIGEST
bash infra/deploy-preview.sh
```

For repository creation from an **extracted source ZIP**, run `scripts/publish-github.ps1` in PowerShell after authenticating GitHub CLI. It initializes Git when necessary, then creates or connects to the private repository.
