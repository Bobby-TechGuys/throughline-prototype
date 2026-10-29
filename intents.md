# intents.md — throughline-prototype (GitHub delivery analytics)

## Purpose
Surface delivery analytics that are buried in GitHub (what shipped, when, how work flows, where process is slipping) on a simple read-only page for client leadership and middle management. Developers keep working from Issues and PRs; this tool asks nothing extra of them.

This prototype runs against my own repo to prove the data model, the GitHub-native hosting path, and exactly what access, credentials, and hosting a client deployment needs.

## Non-goals (prototype)
- No writes to GitHub data (no labels, comments, status changes, Project edits). The only write is publishing the site.
- No GitHub Projects dependency. All data comes from repos: issues, PRs, deployments, releases.
- No per-developer metrics on the leadership view.
- No hosting outside GitHub.

## Audiences and views
**Leadership rollup**
- Shipped timeline: per repo, and per epic where epics exist ("this shipped then").
- Throughput by issue type per week (features vs bugs).
- Epic progress: percent of sub-issues closed, start date, finish or projected date.
- Open bug trend.

**Middle management**
- Cycle time: PR opened → merged.
- Review wait: PR opened → first review.
- Aging: open PRs and issues by age, per repo.
- WIP per repo.
- Unlinked PR share: merged PRs with no linked issue.

**Hygiene report**
- Epic candidates: open > N days with ≥ M linked PRs.
- Should-be-closed: linked PR merged, issue still open.
- Zombies: open, no activity in > N days.
- Orphan work: merged PRs with no linked issue (listed, not only counted).
- Untyped issues.
- Issue lifespan distribution per repo.

All thresholds live in config, not code.

## Definitions
1. **Shipped**: per repo, use the strongest signal available, in this order: a successful deployment to a production environment (Deployments API), then a release or tag, then a merge to the default branch. Record which signal each repo uses and show it on the page.
2. **Linked**: a PR is linked to an issue via `closingIssuesReferences`, or via a cross-reference event in the issue timeline. Track which method produced the link.
3. **Epic**: an issue of type Epic, or any issue with sub-issues.
4. **Activity**: any comment, commit, PR event, or state change.

## Data
- Source: the GitHub GraphQL API, with REST only where GraphQL lacks coverage (e.g. deployment statuses).
- Entities: repos, issues (type, parent and sub-issues, state, timestamps), PRs (state, timestamps, reviews, closing references, base branch), deployments and statuses, releases and tags.
- **Minimization**: store titles, states, timestamps, types, labels, links, and usernames only. Never store issue or PR bodies or comments. The prototype stores exactly what production would publish.
- Sync: full backfill on first run, then incremental by `updatedAt`. Idempotent and re-runnable.
- Storage: snapshots committed to the dashboard repo (SQLite or JSON; choose during build and record why). Keep state-change history; do not just overwrite current state.

## Access
- Start with a fine-grained PAT, read-only, scoped to the test repo only, so the build cannot pick up TG or client data even if a query is too broad.
- Then repeat with a GitHub App and record the minimum permission set. Target: read-only Metadata, Issues, Pull requests, Deployments; no Contents.
- In production the **client creates and owns the App**, not me or TG, so they can revoke it and access doesn't depend on a contractor account.
- Secrets live in Actions secrets only. Never commit or log them.

## Hosting (GitHub-native)
- A scheduled GitHub Actions workflow runs: sync → build the static site → publish.
- Use cross-repo reads via an App token (`actions/create-github-app-token`), not `GITHUB_TOKEN`.
- **Prototype**: publish to public GitHub Pages from my own repo. The test data is not sensitive, but everything on the page (repo names, titles, usernames, timestamps) is world-readable; confirm that's acceptable before the first publish. Add a `noindex` meta tag. The test repo is public, so Pages works on any plan.
- **Production (client on Enterprise Cloud)**:
  - Use a dedicated dashboard repo, separate from code repos. Viewers need read access to it, and that must not grant code access.
  - Set Pages visibility to private, which requires Enterprise Cloud.
  - After the first publish, verify access while signed out and with an account that lacks repo access.
- Keep the publish step isolated in the workflow so moving from prototype to production is a settings change, not a rewrite.

## Findings (primary deliverable)
Maintain `FINDINGS.md` as the build progresses, covering:
1. Minimum token/App permissions, listed per data source.
2. Rate-limit cost and workflow run time for a full backfill and an incremental sync, measured on real repos.
3. Data volume and repo size growth from snapshots over time.
4. Which "shipped" signal each tested repo supports.
5. Features that depend on org-level settings (issue types) or plan tier (private Pages).
6. Actions minutes consumed per scheduled run.
7. Gaps: metrics that can't be computed reliably, and why.
8. Production setup checklist for the client: App creation, dashboard repo, viewer access, Pages visibility, verification.

## Done when
- The scheduled workflow syncs, builds, and publishes end to end from my repo.
- At least one org repo with issue types and sub-issues has been tested (types are org-only).
- All three views render from real data.
- `FINDINGS.md` answers items 1–8 with measured values, not estimates.

## Working rules
- Stage changes for my review; do not push to `main` without asking.
- Ask before adding dependencies.
- Prefer boring, small, readable code over frameworks.

## Open questions
1. Test target: which org repo exercises issue types and sub-issues?
2. Default thresholds for epic candidates (N days, M PRs) and zombies (N days).
3. Does any test repo use GitHub Environments/Deployments, or will "shipped" fall back to merges?
4. Snapshot format: SQLite file or JSON in the repo?
5. Will the client's Enterprise use Enterprise Managed Users? If so, Pages is private-only and visible only to enterprise members, so there are no outside viewers.
6. Do all intended viewers have seats in the client's GitHub org?
