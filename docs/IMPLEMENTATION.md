# Shedbuilt — implementation specification 0.1

## Locked game decisions

- Name: **Shedbuilt**; art direction: gritty Australian backyard / junkyard, corrugated sheds, rough timber, rust, red dirt and eucalypts.
- Platform: **browser-first (desktop browsers)**, no install. Game must run on a hosted HTTPS web page.
- Player camera: first/third switchable. Building: hybrid placement plus meaningful skill-based tool interactions.
- Materials: both manual scavenging in the yard and an inventory interface. Avoid duplicate material claims.
- Build timer: server-configurable per round, 5–30 minutes initially. Timer expiration preserves unfinished parts.
- Multiplayer: private-friends only; solo and team building. Competitive lobbies reset tool/material budgets; career mode persists progression separately.
- Physics intent: physically motivated, legible failure reasons, not laboratory-grade finite element analysis.

## Non-negotiable rules

1. All parts have material, mass, geometry, condition, inertia, and valid/invalid construction interactions.
2. Build graph has parts (nodes) and joints (edges). Build actions cost time and inventory, plus quality altered by skill, preparation, alignment and tools.
3. Simulation controls stress, shear, tension, bending, impacts, progressive joint damage and separations. Adhesives also depend on peel angle/surface preparation.
4. Build state is separate from live physical race simulation. Save every authorized build operation to an event log for replay/audit.
5. Only the server approves construction and decides results; client sends intentions and may render predicted previews.
6. Progression must not add statistical advantage to standardized competitive rounds.
7. Sensor-style notebook reports only measured/estimated evidence from the simulation and must label uncertainty.

## Core systems

- **Part library** (`shared/parts.json`): dimensioned parts with condition and actionable tool/material capabilities.
- **Construction** (`shared/joints.json`, `godot/scripts/physics/JointModel.gd`): fasteners consume time and resources; grades modeled with force/moment capacity curves. Never equate tape with welding.
- **World** (`godot/scripts/Main.gd`): procedural proving yard, hill, camera, UI, simple sample vehicle and physical joint.
- **Gameplay server** (`godot/scripts/network/GameNetwork.gd`): initial WebSocketMultiplayerPeer/command validation. Full server auth/replay are follow-up work.
- **Challenge** (`shared/challenges/big_hill.json`): conditions, phases and scoring. Great Splash adds lift, buoyancy and water impact only after hill benchmark passes.
- **Career** (future): separate Go API + PostgreSQL, workshop/tool progression, saved blueprints and match history.

## Authoritative state contract (target)

Transport: WSS via Traefik. Client sends JSON-equivalent intent `{match_id, action_id, op, part_id, attachment_id, method, transform, client_timestamp}` (implemented as typed RPCs later). Server validates identity, phase, tool possession, permission, part budget, interaction range, allowable material joining, inventory locks and cooldown. On success: apply cost and quality to authoritative assembly graph, append event, emit confirmed delta and sequence number. Reject duplicate IDs. Snapshot graph on rejoin. Race is simulated on server, sends snapshots at 10–20Hz (interpolate client-side), records events/final score.

## Work-time model

`effective_time = base_seconds * tool_multiplier * skill_multiplier * access_multiplier * alignment_multiplier`. Team speedup must be sublinear. If timer expires, unfinished joins remain in-progress and afford no strength. Real-world durations are compressed but **relative technique costs** are preserved.

## Failure model

`utilization = sqrt((F_shear/S_shear)^2 + (F_tension/S_tension)^2 + (M/M_capacity)^2)`.

When utilization exceeds 1, damage increases. Catastrophic overload breaks instantly. Multiple-frame fatigue increases damage. Every failure emits a reason and joint ID. These are simple approximations; tuning is required, and moment loads are not fully captured by current PoC.

## MVP acceptance

- A player can place at least 20 reusable materials/parts and join objects by tape, bolt and weld.
- Distinct time and strength, and visible failed joint/debris outcomes.
- At least one build-and-race hill challenge completes solo in browser.
- Four private remote players can join server, collaborate and race with authoritative results.
- Repeatable 60Hz headless simulation on benchmark map without physics instability at supported part limits.
- Smoke tests validate WSS, version handshake, clean reconnect and no unauthenticated build mutations.
- Android/iOS browsers are non-goals for the first version; focus on Chromium/Firefox desktop.
