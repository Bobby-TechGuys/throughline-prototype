# FINDINGS

Measured results from the throughline prototype. Every value here comes from a real run, not an estimate. Each entry notes the date and the repo it was measured on.

Status: **not started**. Sections are filled in as the build progresses.

## 1. Minimum token / App permissions, per data source

| Data source | Fine-grained PAT | GitHub App | Notes |
|---|---|---|---|
| Repo metadata | | | |
| Issues (types, sub-issues, timeline) | | | |
| Org issue types (REST) | | | GraphQL `organization.issueTypes` is forbidden for fine-grained PATs; REST works |
| Pull requests (reviews, closing refs) | | | |
| Deployments + statuses | | | |
| Releases / tags | | | |
| Publish (Pages) | n/a | n/a | Uses workflow `GITHUB_TOKEN` |

## 2. Rate-limit cost and run time

| Run | Repo | GraphQL points | REST calls | Wall time |
|---|---|---|---|---|
| Full backfill | | | | |
| Incremental | | | | |

## 3. Data volume and repo growth

_Snapshot size per run, and `.git` growth over N runs._

## 4. "Shipped" signal per repo

| Repo | Signal used | Why |
|---|---|---|

## 5. Org-setting and plan-tier dependencies

- Issue types: org-level setting.
- Private Pages: Enterprise Cloud only.

## 6. Actions minutes per scheduled run

## 7. Gaps

_Metrics that can't be computed reliably, and why._

## 8. Client production setup checklist

- [ ] Client creates and owns the GitHub App (minimum permissions from section 1)
- [ ] Dedicated dashboard repo, separate from code repos
- [ ] Viewer access to the dashboard repo without code access
- [ ] Pages visibility set to private
- [ ] Verify access signed out and with an account lacking repo access
