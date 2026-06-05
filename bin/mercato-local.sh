#!/usr/bin/env bash
# On-demand local launcher: start the app + infra when you open it, stop both when you close it.
# Usage:
#   bin/mercato-local.sh dev    # live-reload dev server (yarn dev)        — for coding
#   bin/mercato-local.sh up     # production server (yarn build && start)  — for using/demoing
#   bin/mercato-local.sh down   # stop the app + park the containers (RAM reclaimed)
#
# In dev/up mode the script runs in the foreground: press Ctrl+C to close, which also
# stops the Docker services. Nothing is left running 24/7.
set -uo pipefail
cd "$(dirname "$0")/.."

PORT="$(grep -E '^PORT=' .env 2>/dev/null | head -1 | cut -d= -f2 | tr -d '[:space:]')"
PORT="${PORT:-3100}"
URL="http://localhost:${PORT}/backend"
CMD="${1:-dev}"

stop_app() { lsof -ti tcp:"${PORT}" 2>/dev/null | xargs kill 2>/dev/null || true; }

open_when_ready() {
  for _ in $(seq 1 150); do
    if curl -sS -o /dev/null --max-time 2 "$URL"; then open "$URL"; return; fi
    sleep 2
  done
}

case "$CMD" in
  down)
    echo "▶ closing: stopping app + infra…"
    stop_app
    docker compose stop
    echo "✓ closed. Containers parked (data kept), RAM reclaimed. Reopen with: yarn dev:up / yarn app:up"
    ;;
  up|prod|dev)
    MODE="$CMD"; [ "$MODE" = "up" ] && MODE="prod"
    cleanup() { echo; echo "▶ closing: stopping infra…"; docker compose stop; echo "✓ infra parked, RAM reclaimed."; }
    trap cleanup EXIT INT TERM

    echo "▶ starting infra (Postgres/Redis/Meilisearch)…"
    docker compose up -d --wait

    open_when_ready &

    if [ "$MODE" = "prod" ]; then
      echo "▶ build + start (production) on :${PORT} — Ctrl+C closes everything"
      yarn build && yarn start
    else
      echo "▶ dev server (live-reload) on :${PORT} — Ctrl+C closes everything"
      yarn dev
    fi
    ;;
  *)
    echo "usage: bin/mercato-local.sh [dev|up|down]"; exit 1 ;;
esac
