# Shedbuilt — Codex implementation handoff

You are extending Shedbuilt, a web-first Godot 4.6 multiplayer physics invention game. Do not discard the existing work or falsely assert features are tested. Start by reading `README.md`, `docs/IMPLEMENTATION.md`, `docs/ARCHITECTURE.md`, and `docs/ROADMAP.md`.

## Current operator-approved deployment direction (October 2026)
- Project: `Shedbuilt`, private GitHub target `virtualhowto/Shedbuilt`.
- Approved production hostname: `shedbuilt.virtualhowto.com`.
- First online deliverable is *only* the standalone physics lab behind existing Traefik + Authentik forward authentication. Read `docs/GO-LIVE.md` and keep `infra/deploy.sh` disabled.
- Do not enable Internet-reachable Godot multiplayer or remove Authentik checks until invitation, authorization, session and RPC tests are implemented and passing.
- The latest archive includes a Windows publishing helper: `scripts/publish-github.ps1`.

## Stage 1: Validate existing artifact
1. Install the pinned Godot 4.6 Standard editor and export templates; validate exact checksums, populate repository variables.
2. Run `node --test tests/*.test.mjs`, `python scripts/validate_catalogue.py`, `godot --headless --path godot --editor --import --quit`, and Godot fixture script. Diagnose/fix any GDScript syntax or scene problems.
3. Export Godot Web and Linux headless artifacts, smoke-test both. Run in Chromium/Firefox via HTTPS (desktop); record console errors and frame time. Never substitute native PC screenshot for Web testing.
4. Validate Traefik web/WSS routing in a local staging environment.

## Stage 2: Real physics and construction
5. Replace the single prototype axle joint with a generic authoritative part/edge graph: 20-30 parts with legal attachment, sub-frame mass/inertia and validated joints.
6. Use rolling wheel colliders / suspension / raycast contact physics instead of decorative wheels. Ensure gravity, traction, alignment and center-of-mass matter.
7. Compute connection load from relative forces/impulses and bending estimates, not the current diagnostic z-position threshold; add quality, damage accumulation and failed-part detachment.
8. Build hybrid placement UI: ghost geometry, snapping, manual rotation, tool-specific timed interactions and incremental build completion. Build skills should reward player technique but not auto-complete construction.
9. Add scavenging and inventory, locked by server budgets. Add configurable time limits.
10. Run automatic physics scenarios at 60Hz, compare tape/bolts/weld and produce failure explanations.

## Stage 3: Multiplayer security and complete round
11. Replace `GameNetwork.gd` development password with expiring invite tokens, rate limits, session identity, scoped per-lobby permissions, validated state mutations and reconnect. WebSocket over WSS, no direct UDP exposure.
12. Implement authoritative lobby state machine: scavenge, build, test, race, results. Handle team interlocks, contention, dropped connections and late joins.
13. Server-only race scoring, checkpoints and recorded telemetry. Build replays from authoritative snapshots, not assumed cross-platform deterministic floating point.
14. Four-client headless integration stress test, aggressive malformed RPC fuzzing and reconnection tests.
15. Enforce protected production promotion, image vulnerability scans, digest-pinned images, environment approvals and automatic post-deployment smoke tests. Update version and build hash in HUD.

## Constraints
- Visual style: gritty authentic Australian junkyard, not cartoonish.
- Browser first, no Windows client dependency; responsive desktop UI and WebGL 2.0.
- Private friends-only until auth is complete. Solo and team modes.
- Fast placement plus hands-on technique; configurable build time.
- Realistic relative joint capability and work effort; physics-based scoring.
- Keep all data and schema definitions under `shared/`; avoid fabricated physics claims.
- Do not expose production directly or skip release checks to get a working demo.

## Expected deliverables
Small reviewed commits, updated runnable Godot Web export, passing CI, reproducible Docker staging setup, instrumented physics scenario suite, changelog and a clear list of unimplemented features.
