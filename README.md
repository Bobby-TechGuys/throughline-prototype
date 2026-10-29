# throughline-prototype

Read-only delivery analytics for GitHub repos: what shipped, when, how work flows, and where process is slipping. Built for client leadership and middle management, with nothing extra asked of developers.

See [intents.md](intents.md) for scope and definitions, and [FINDINGS.md](FINDINGS.md) for measured results (the primary deliverable).

## How it works

A scheduled GitHub Actions workflow runs **sync → build → publish**:

1. **Sync** (`src/sync.js`) reads issues, PRs, deployments, and releases from the repos in `config.json` using the GraphQL API (REST where GraphQL lacks coverage). It writes snapshots to `data/` and commits them, keeping state-change history.
2. **Build** (`src/build.js`) turns the snapshots into a static site in `site/`.
3. **Publish** deploys `site/` to GitHub Pages.

No writes to GitHub data. No bodies or comments are stored: titles, states, timestamps, types, labels, links, and usernames only.

## Layout

```
config.json        targets, thresholds, production env names
check-token.sh     verifies a token can read everything sync needs
src/               sync, store, metrics, build, render (plain Node, no deps)
data/state/        current-state JSON snapshots per entity
data/history/      append-only NDJSON change log
test/              node --test
.github/workflows/ scheduled sync → build → publish
```

## Running locally

Requires Node 22+. No `npm install` needed.

```bash
export THROUGHLINE_TOKEN=...   # fine-grained PAT, read-only, scoped to the target repos
./check-token.sh BobbyTG-Organization throughline-prototype
npm run sync
npm run build
npm test
```

## Access

- **Prototype:** a fine-grained PAT, read-only on Metadata, Issues, Pull requests, and Deployments, scoped to the target repo only. It is stored as the Actions secret `THROUGHLINE_TOKEN`.
- **Next:** a GitHub App via `actions/create-github-app-token`. In production the client creates and owns the App.

Secrets live in Actions secrets only. Never commit or log them.
