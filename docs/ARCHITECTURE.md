# Browser-first architecture & security decisions

## Choice

**Godot 4.6 Web export** runs client in browser (WebAssembly + WebGL 2.0 compatibility). A matching **Godot 4.6 headless Linux** game process runs physics on server. Start with the built-in GodotPhysics3D on both to minimize client/server behavioural drift, not full physics determinism. GDScript only. No .NET, no runtime native plugins required.

**Transport:** WSS `/ws` to Godot WebSocket server (single game process initially). Traefik terminates TLS; WebSockets work over HTTPS ingress. One replica avoids ambiguous placement or sticky-session issues. Docker Swarm publishes no UDP gameplay port. Browser tab throttling is real: handle disconnect and pause/rejoin.

**Security:** HTTPS, strict host routing, Origin filtering and short-lived, hashed invitations with lobby capacity limits will be needed before online friends testing. The illustrative env-based password in the starter RPC is only a development gate; it is not production authorization. Never expose directly on untrusted networks. Avoid assuming web proxy auth alone protects Godot RPCs. Add server-issued session tokens and rate limits.

**Deployed components:**

- `web`: Nginx serves versioned immutable Godot Web export and health endpoint through Traefik.
- `game`: Godot headless WebSocket authority internal-only, routed as WSS on `/ws` by Traefik. No direct port published.
- `api` + `postgres` later, for careers/invites/replays.
- Observability via Swarm logs, metrics and trace IDs; pin version manifest / SHA in HUD.

**Preflight:** web export template exists, correct Godot build hash, same physics engine in both variants, Traefik on same overlay, DNS/TLS ready, game node Swarm label set, secret provisioned, disk backup location known, browser WSS tests from outside, Authentik policy explicit, image digests resolvable.

**Risk:** WebGL 2.0 performance under numerous active RigidBody3D objects; Godot browser tab throttling; 4.6 web export bugs; high-frequency transforms over WSS/TCP; no guaranteed deterministic replay; joint behavior differences. Test at 20, 40 and 80 components before promising more. Optimize authority first, reduce replicated update rate, interpolate visual state. Explore WebRTC datagrams later if genuinely necessary.

## Production deployment gating

No automatic production push from a pull request. Require protected `main` branch, secret scan, deterministic physics fixtures, Godot script import, headless run, Linux game export, web export smoke test, dependency/image scan, PR review, staging post-deploy browser handshake, explicit environment approval, deployment digest log, and rollback procedure.

No exposed public access until invitation auth and authorization gates are implemented and tested.
