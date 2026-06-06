# Project State

_Last updated: 2026-06-06_

## What this is

A **standalone [Open Mercato](https://github.com/open-mercato/open-mercato) app** — the base for a business product built on top of Open Mercato, an MIT-licensed "AI-Engineering Foundation Framework" (Next.js 16 + MikroORM/PostgreSQL + Redis + Meilisearch; modular monolith, multi-tenant, RBAC, AI-agent-extendable).

It consumes the framework as `@open-mercato/*` **npm packages** (zero-modification core), so tracking upstream releases is a version bump, not a fork merge. Your code lives under `src/`; core stays on npm.

- **Repo:** `github.com/hlebtkachenko/mercato`
- **Branch:** `hlebtkachenko/open-mercato-app-scaffold` (merged to `main`)
- **Scaffolded with:** `create-mercato-app` (classic preset)

## Current status

| Area | State |
|---|---|
| Scaffold | Done — classic preset, **all 53 modules kept** (no trimming, by choice) |
| Boots | Yes — backend at `/backend` |
| `yarn typecheck` | Green |
| `yarn test` | Green (harness fixed — see Fixes) |
| Infra | docker-compose (Postgres pgvector / Redis / Meilisearch), on-demand |
| CI | Green — `generate` + typecheck + test + gitleaks on every push/PR |
| Git | Pushed to the branch **and `main`** |

## Decisions

- **Standalone path** over monorepo clone — keeps upstream upgrades a version bump.
- **All modules kept** (classic enables every built-in module + demo modules `example`, `example_customers_sync`, `ratelimit_probe`). Not trimming.
- **Non-standard ports** — don't squat ports another service may need (via the compose env overrides).
- **Real tenant encryption key** — dev fallback disabled.
- **On-demand launcher** — runs only while open, like a desktop app.

## Local config (in `.env`, gitignored)

| Service | Port | Var |
|---|---|---|
| App | 3100 | `PORT` |
| Postgres | 5433 | `POSTGRES_PORT` + `DATABASE_URL` |
| Redis | 6390 | `REDIS_PORT` + `REDIS_URL` |
| Meilisearch | 7710 | `MEILISEARCH_PORT` + `MEILISEARCH_HOST` |

- `TENANT_DATA_ENCRYPTION_KEY` set (real key); `TENANT_DATA_ENCRYPTION_FALLBACK_KEY` disabled. `JWT_SECRET` set.
- `.env` is never committed; `.env.example` is the template.

## Run it (on-demand)

| Command | What |
|---|---|
| `yarn dev:up` | Start infra + dev server (live-reload), opens browser. Ctrl+C closes everything. |
| `yarn app:up` | Start infra + production server (`build && start`). Lighter. |
| `yarn app:down` | Stop the app + park containers (RAM reclaimed). |

- Backend: `http://localhost:3100/backend`
- Seed users: `superadmin@acme.com` / `admin@acme.com` / `employee@acme.com`, password `secret`
- Containers are `restart: "no"` → never auto-start on Docker boot; run only when you open the app.
- Launcher: `bin/mercato-local.sh`.

## Repo layout (key paths)

```
src/modules.ts            # enabled-modules registry (all 53)
src/modules/<id>/         # your modules (+ demo modules as reference)
src/app/                  # (backend)/backend admin, (frontend), api dispatcher, landing
.env / .env.example       # local config / template
docker-compose.yml        # local infra (designed ports + overrides)
bin/mercato-local.sh      # open/close launcher
jest.config.cjs           # test harness (added — see Fixes)
.ai/                      # specs, skills, guides (agentic)
CLAUDE.md / AGENTS.md      # AI-agent guidance
.mcp.json.example         # MCP config template
```

## Fixes applied this session

- **Ports** moved off standard 3000/5432/6379/7700 via the compose env overrides.
- **Encryption**: real `TENANT_DATA_ENCRYPTION_KEY`, dev fallback disabled, DB reseeded under it.
- **Agentic tooling**: `yarn mercato agentic:init --tool claude-code` (CLAUDE.md, `.claude/hooks/`, `.mcp.json.example`, `.ai/`).
- **On-demand launcher** + `restart: "no"` so nothing runs 24/7.
- **Test harness**: the scaffold shipped a `test` script (`jest --config jest.config.cjs`) but **no config and no test files** (the generator strips `__tests__`), so `yarn test` crashed. Added a self-contained `jest.config.cjs` + `scripts/jest-mikroorm-transformer.cjs` + `jest.setup.ts` / `jest.dom.setup.ts` (adapted from the monorepo: `@open-mercato/*` resolve from `node_modules`), plus a smoke test. `yarn test` is now green.

## Repo quality / CI

- **`.gitignore` hardened** — ignores every `.env*`, plus `*.key`/`*.p12`/`*.pfx`/`id_rsa*`.
- **CI** (`.github/workflows/ci.yml`) — `yarn generate` + typecheck + test, and gitleaks secret scan, on every push/PR.
- **Dependabot** (`.github/dependabot.yml`) — weekly npm + github-actions updates; `@open-mercato/*` grouped; majors held for manual review.
- **README.md**, **.editorconfig**, **.nvmrc** (Node 24) added.
- **`main` branch protection** (ruleset `protect-main`) — every change must land via a PR with `typecheck + test` + `gitleaks` green; direct pushes, force-pushes, and branch deletion are blocked (no bypass).

## Contributing flow

`main` is PR-only:

```bash
git checkout -b <change>
git push origin <change>
gh pr create --base main
# CI green (typecheck + test + gitleaks) -> merge
```

## Keeping current with upstream

```bash
yarn up '@open-mercato/*'
yarn generate
yarn db:migrate
```

## Build a module (no restart for most changes)

1. `module-scaffold` skill → create `src/modules/<id>/` + register `{ id, from: '@app' }` in `src/modules.ts`
2. Entities in `data/entities.ts` → `yarn db:generate && yarn db:migrate`
3. API via the CRUD factory
4. Backend page + `page.meta.ts` → appears in the sidebar
5. `yarn generate` (structural changes; live, no restart)

Tests for your modules go under `src/modules/<id>/**/__tests__/*.test.ts` and run with `yarn test`.

## Commits

- `2dc0882` feat: scaffold standalone Open Mercato app
- `befc8e1` chore: add Claude Code agentic tooling
- `fe1321c` feat: on-demand local launcher
- `10e23a4` fix: working jest test harness + state.md
- `b4ed63d` chore: harden .gitignore against secret leaks
- `dfbf8c2` chore: add README, CI, secret scanning, Dependabot, editor config
- (+ this) docs: update state.md and merge to main

## Next

Decide the **business domain** → scaffold the first real module end-to-end.
