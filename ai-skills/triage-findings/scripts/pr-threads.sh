#!/usr/bin/env bash
# Print a PR's review threads, review summaries and conversation comments.
# Usage: pr-threads.sh [pr-number-or-url] [--all]   (default: unresolved threads only)
set -euo pipefail
pr=${1:-}
[[ $pr == --all ]] && pr=""
all=false
for a in "$@"; do [[ $a == --all ]] && all=true; done

read -r owner repo number < <(gh pr view ${pr:+"$pr"} --json url --jq '.url | capture("github.com/(?<o>[^/]+)/(?<r>[^/]+)/pull/(?<n>[0-9]+)") | "\(.o) \(.r) \(.n)"')

gh api graphql -F owner="$owner" -F repo="$repo" -F n="$number" -f query='
query($owner: String!, $repo: String!, $n: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $n) {
      title url headRefOid
      reviews(last: 30) { nodes { author { login } state submittedAt body } }
      comments(last: 50) { nodes { author { login } createdAt body } }
      reviewThreads(first: 100) { nodes {
        isResolved isOutdated path line originalLine
        comments(first: 30) { nodes { author { login } createdAt body } }
      } }
    }
  }
}' | jq -r --argjson all "$all" '.data.repository.pullRequest | [
  "\(.title)\n\(.url)\nhead: \(.headRefOid[:12])",
  "", "==== reviews",
  (.reviews.nodes[] | select(.body != "" or .state != "COMMENTED") | "-- \(.author.login) \(.state) \(.submittedAt[:10])", (.body | select(. != ""))),
  "", "==== conversation",
  (.comments.nodes[] | "-- \(.author.login) \(.createdAt[:10])", .body),
  "", "==== threads",
  (.reviewThreads.nodes[] | select($all or (.isResolved | not)) |
    "", "## \(.path):\(.line // .originalLine)\(if .isResolved then " [resolved]" else "" end)\(if .isOutdated then " [outdated]" else "" end)",
    (.comments.nodes[] | "-- \(.author.login) \(.createdAt[:10])", .body))
] | .[]'
