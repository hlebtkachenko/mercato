# Mercato

A standalone [Open Mercato](https://github.com/open-mercato/open-mercato) application — the base for a business product built on top of the framework.

Open Mercato is an MIT-licensed "AI-Engineering Foundation Framework": Next.js 16 + MikroORM/PostgreSQL + Redis + Meilisearch, modular monolith, multi-tenant, RBAC. This app consumes the framework as `@open-mercato/*` npm packages (zero-modification core), so upstream releases are a version bump rather than a fork merge.

See **[state.md](./state.md)** for the full current state, decisions, and layout.

## Prerequisites

- Node.js **24+** (`.nvmrc` pins 24)
- Corepack + Yarn 4 (`corepack enable`)
- Docker (for Postgres, Redis, Meilisearch)

## Quick start

```bash
corepack enable
yarn install
cp .env.example .env          # then set DATABASE_URL, JWT_SECRET, REDIS_URL
docker compose up -d --wait   # Postgres + Redis + Meilisearch
yarn db:migrate               # apply migrations
yarn initialize               # seed data + admin users
yarn dev                      # http://localhost:3100/backend
```

`.env` in this checkout already runs on non-standard ports (app 3100, Postgres 5433, Redis 6390, Meili 7710) to avoid clashing with other local services.

## Run it on demand (open/close like a desktop app)

| Command | What it does |
|---|---|
| `yarn dev:up` | Start infra + dev server (live-reload), opens the browser. Ctrl+C closes everything. |
| `yarn app:up` | Start infra + production server (`build && start`). Lighter. |
| `yarn app:down` | Stop the app and park the containers (RAM reclaimed). |

Nothing runs 24/7: containers are `restart: "no"` and only run while the app is open.

## Common scripts

| Command | Purpose |
|---|---|
| `yarn dev` | Dev server (HMR) |
| `yarn build` / `yarn start` | Production build / server |
| `yarn generate` | Regenerate `.mercato/generated/` after structural module changes |
| `yarn db:generate` / `yarn db:migrate` | Create / apply migrations |
| `yarn typecheck` | `tsc --noEmit` |
| `yarn test` | Jest unit tests |

## Building a module

1. Create `src/modules/<id>/` and register `{ id, from: '@app' }` in `src/modules.ts`
2. Define entities in `data/entities.ts` → `yarn db:generate && yarn db:migrate`
3. Add API routes (CRUD factory) and a backend page (`page.meta.ts` puts it in the sidebar)
4. `yarn generate`

Tests live under `src/modules/<id>/**/__tests__/*.test.ts`.

## Updating the framework

```bash
yarn up '@open-mercato/*'
yarn generate
yarn db:migrate
```

## Contributing

`main` is protected — changes land via PR only (no direct pushes). CI must pass (`typecheck + test` + `gitleaks`) before merge.

```bash
git checkout -b <change>
git push origin <change>
gh pr create --base main
```

## Security notes

- Real secrets live only in `.env` (gitignored). `.env.example` holds placeholders.
- This app uses a real `TENANT_DATA_ENCRYPTION_KEY` (the dev fallback is disabled).
- **Before any production deploy:** the `docker-compose.fullapp*.yml` files ship dev defaults (`NODE_ENV=development`, `DEMO_MODE=true`, `JWT_SECRET=JWT`, dev encryption/Meilisearch keys, `superadmin` password `password`). Override every secret env var, set `NODE_ENV=production`, rotate the seeded `@acme.com` credentials, and prefer a Vault/KMS-backed encryption key.
- CI runs typecheck, tests, and gitleaks secret scanning on PRs and `main` (dependency-cached; also runnable manually via `gh workflow run CI`).

## License

Proprietary. The underlying Open Mercato framework is MIT-licensed.
