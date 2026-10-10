# Roadmap and honest completion state

- [x] Design locked: Shedbuilt, web-first, cameras, inventory/scavenging, skill tools, configurable time, friends-only.
- [x] Browser physics *lab* based on an explicit simplified 2D dynamics model (local only).
- [x] Foundational Godot 3D project, scene and GDScript physics/joint model authored.
- [x] Config-driven joint/parts/challenge examples.
- [x] Node tests and GitHub Actions workflow source.
- [x] Template Docker Compose lab + Swarm production topology.
- [ ] Execute Godot headless scripts/import/export using a provisioned engine and templates; not executable in artifact generation environment.
- [ ] User-tested WebGL 2.0 Godot export and tool interactions in browser.
- [ ] True multi-assembly joint graph (test 20+ parts, aligned axles, material bending/fatigue).
- [ ] Full construction actions with server-side inventory, timer, locks, cost and technique minigames.
- [ ] Server-authoritative four-player complete race with anti-cheat and reconnect.
- [ ] Short-lived invite auth, lobby capacity, connection rate limiting, auth tests.
- [ ] Automated rendered client smoke test and CI image signed deployment.
- [ ] Persist blueprints/career and implement alternate Splash physics.

## Follow-up issue suggestions

1. **P0** Godot scene headless runtime/export validation on pinned toolchain.
2. **P0** Part graph model and Pin/Hinge joint alignment fixtures.
3. **P0** Character controls + first/third-person interaction and scavenging.
4. **P0** Private invite validation and full authoritative build protocol.
5. **P1** Round state machine, server time, scoring and results.
6. **P1** Cross-browser physics performance benchmarks.
7. **P1** Post-run Engineering Notebook.
8. **P2** Great Splash hydrodynamics.
