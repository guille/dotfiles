#!/usr/bin/env bash
# Convert a plain checkout into the bare + worktree layout.
# The original is left beside it as <name>.pre-worktree; nothing is deleted.
set -euo pipefail

usage() {
	cat >&2 <<-EOF
		usage: $(basename "$0") <checkout-path> [primary-branch]

		  SHARED_LOCAL   space-separated ignored files to share across worktrees
		                 via local/ (default: mise.local.toml)
		  SKIP_LOCAL     space-separated path prefixes to leave behind instead
		                 of carrying over, for regenerable build output
		  ALLOW_UNPUSHED=1  proceed despite commits that exist on no remote;
		                 every ref is first saved to <checkout-path>.pre-worktree.bundle
	EOF
	exit 2
}
[ $# -ge 1 ] || usage

src=$(cd "$1" 2>/dev/null && pwd) || { echo "no such directory: $1" >&2; exit 1; }
shared=${SHARED_LOCAL:-mise.local.toml}
skip=${SKIP_LOCAL:-}
hook=$(dirname "$(readlink -f "$0")")/post-checkout

[ -d "$src/.git" ] || { echo "not a plain checkout (no .git dir): $src" >&2; exit 1; }
[ -e "$src.pre-worktree" ] && { echo "backup already exists: $src.pre-worktree" >&2; exit 1; }

cd "$src"
primary=${2:-$(git symbolic-ref --short HEAD)}

# --- refuse to proceed if anything could be lost ---
# untracked and ignored files are fine: they get carried over below.
fail=0
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
	echo "ABORT: uncommitted changes to tracked files" >&2
	git status --short --untracked-files=no >&2; fail=1
fi
if [ -n "$(git stash list)" ]; then
	echo "ABORT: stashes present" >&2; git stash list >&2; fail=1
fi
unpushed=$(git log --oneline --branches --not --remotes)
if [ -n "$unpushed" ] && [ "${ALLOW_UNPUSHED:-}" != 1 ]; then
	echo "ABORT: commits that exist on no remote:" >&2; echo "$unpushed" >&2
	echo "(push them, or rerun with ALLOW_UNPUSHED=1: refs move with .git untouched)" >&2; fail=1
fi
[ "$fail" = 0 ] || { echo "nothing was changed." >&2; exit 1; }

# refs survive the .git move, but unpushed work has no other copy: keep one
bundle=
if [ -n "$unpushed" ]; then
	bundle=$src.pre-worktree.bundle
	git bundle create "$bundle" --all >/dev/null 2>&1
	git bundle verify "$bundle" >/dev/null 2>&1
fi

# --- record untracked+ignored files while the index is still readable ---
locals=()
while IFS= read -r -d '' entry; do
	case "${entry:0:2}" in '??' | '!!') locals+=("${entry:3}") ;; esac
done < <(git status --porcelain -z --ignored=matching -uall)

# --- the old .git becomes the bare repo ---
bak=$src.pre-worktree
mv "$src" "$bak"
mkdir -p "$src/local"
mv "$bak/.git" "$src/.git"
git -C "$src/.git" config core.bare true
install -m 755 "$hook" "$src/.git/hooks/post-checkout"

# --- promote the shared config, then create the primary worktree ---
for f in $shared; do
	[ -e "$bak/$f" ] || continue
	mkdir -p "$src/local/$(dirname "$f")"
	mv "$bak/$f" "$src/local/$f"
done

cd "$src"
git worktree add "$primary" "$primary"

# --- carry every remaining local file into the primary worktree ---
left_behind=()
for f in "${locals[@]}"; do
	f=${f%/} # git reports wholly-ignored directories with a trailing slash
	[ -e "$bak/$f" ] || continue # promoted to local/ above
	drop=0
	for p in $skip; do
		case "$f" in "${p%/}" | "${p%/}"/*) drop=1; break ;; esac
	done
	if [ "$drop" = 1 ]; then
		left_behind+=("$f")
		continue
	fi
	mkdir -p "$primary/$(dirname "$f")"
	cp -a "$bak/$f" "$primary/$f"
done

# --- report ---
echo
git worktree list
echo
echo "shared via local/:"
find local -mindepth 1 \( -type f -o -type l \) -printf '  %P\n' 2>/dev/null || echo "  (none)"
if [ ${#left_behind[@]} -gt 0 ]; then
	echo
	echo "left behind (SKIP_LOCAL), regenerate in $primary/:"
	printf '  %s\n' "${left_behind[@]}"
fi
echo
echo "primary worktree ($primary) git status:"
git -C "$primary" status --short || true
echo
echo "backup kept at: $bak"
[ -z "$bundle" ] || echo "all refs bundled at: $bundle"
echo "verify, then: rm -rf '$bak'${bundle:+ '$bundle'}"
