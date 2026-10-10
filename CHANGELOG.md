# Shedbuilt changelog

## 0.2.0-preview-infra — 10 October 2026
- Locked approved public hostname `shedbuilt.virtualhowto.com` for future private access.
- Added an isolated Authentik/Traefik-gated Swarm preview stack serving the standalone physics laboratory only.
- Added GHCR image-publishing and manual approved preview-promotion workflows.
- Added version.json with immutable source commit SHA to preview container.
- Added Windows PowerShell helper to create/connect private GitHub repo and push project.
- Disabled the incomplete multiplayer deployment workflow and prevented its manual deployment script.
- Added four browser lab and preview deployment tests (13 passing Node tests total).
- Documented DNS, Authentik, Swarm and GitHub bootstrap runbook.

## 0.1.0-lab — 10 October 2026
- Initial Godot physics proving-yard scaffold and browser mechanics laboratory.
- Simplified joint-strength and construction-time models.
- Nine Node tests, starter catalogues, multiplayer skeleton and CI scaffolding.

**Build status:** Node and catalogue tests verified in the creation environment. Godot runtime and Docker deployment are not verified here, and no live infrastructure has been modified.
