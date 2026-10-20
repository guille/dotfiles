#!/usr/bin/env bash
# Clone a repo straight into the bare + worktree layout.
set -euo pipefail

usage() {
	echo "usage: $(basename "$0") <git-url> [dir-name] [primary-branch]" >&2
	exit 2
}
[ $# -ge 1 ] || usage

url=$1
dir=${2:-$(basename "${1%.git}")}
hook=$(dirname "$(readlink -f "$0")")/post-checkout

[ -e "$dir" ] && { echo "already exists: $dir" >&2; exit 1; }
root=$(mkdir -p "$dir" && cd "$dir" && pwd)

# init+fetch rather than `clone --bare`: a bare clone drops every remote branch
# into refs/heads/* and sets no fetch refspec, so `git branch` is a mess and
# `git worktree add <branch>` cannot DWIM a tracking branch.
git init --bare -q "$root/.git"
cd "$root"
git remote add origin "$url"
git fetch --prune --quiet origin
git remote set-head origin -a

primary=${3:-$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')}

mkdir -p local
install -m 755 "$hook" .git/hooks/post-checkout

git worktree add "$primary" "$primary"

echo
git worktree list
echo
echo "put shared untracked config in $root/local/ (e.g. mise.local.toml),"
echo "then run 'git checkout $primary' inside $primary/ to link it."
