#!/usr/bin/env bash
# Checks that THROUGHLINE_TOKEN can read everything throughline-prototype needs.
# Usage: THROUGHLINE_TOKEN=... ./check-token.sh <org> <repo> [private-owner/private-repo]
# Requires: gh CLI, jq. The token is read from the environment, never passed as an argument.
set -uo pipefail   # no -e: each check reports on its own, one failure doesn't hide the rest

ORG="${1:?org required}"; REPO="${2:?repo required}"; PRIVATE="${3:-}"
export GH_TOKEN="${THROUGHLINE_TOKEN:?set THROUGHLINE_TOKEN}"

echo "== 1. Auth (limit should be 5000, not 60)"
gh api rate_limit --jq '.resources.core | "limit=\(.limit) remaining=\(.remaining)"'

echo "== 2. Org issue types via REST (needs Issue Types: read)"
echo "   (GraphQL organization.issueTypes is FORBIDDEN for fine-grained PATs even with this permission; REST works)"
gh api "orgs/$ORG/issue-types" --jq '.[].name' || echo "FAILED: org issue types"

echo "== 3. Repo data (issues, types, sub-issues, PRs, deployments, releases)"
gh api graphql -f query='
query($o:String!,$r:String!){
  repository(owner:$o,name:$r){
    issues(first:5,orderBy:{field:UPDATED_AT,direction:DESC}){
      nodes{ number title state issueType{name} parent{number} subIssues(first:5){totalCount} } }
    pullRequests(first:5,orderBy:{field:UPDATED_AT,direction:DESC}){
      nodes{ number state mergedAt closingIssuesReferences(first:5){nodes{number}} reviews(first:1){totalCount} } }
    deployments(first:5){ nodes{ environment createdAt latestStatus{state} } }
    releases(first:5){ nodes{ tagName publishedAt } }
  } }' -f o="$ORG" -f r="$REPO" | jq '{data: .data.repository, errors}' || echo "FAILED: repo data (see errors above)"

if [[ -n "$PRIVATE" ]]; then
  echo "== 4. Negative test: private repo should be NOT readable"
  if gh api "repos/$PRIVATE" >/dev/null 2>&1; then
    echo "WARNING: token can read $PRIVATE — scope is wider than intended"
  else
    echo "OK: $PRIVATE not readable"
  fi
fi
