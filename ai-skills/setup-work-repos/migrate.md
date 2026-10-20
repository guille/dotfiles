# Migrating an existing checkout

```bash
<skill-dir>/scripts/migrate-repo.sh ~/work/<repo> [primary-branch]
```

The primary branch defaults to the currently checked-out one. The script:

1. Refuses to touch anything if there are uncommitted changes to **tracked**
   files, stashes, or commits that exist on no remote. Untracked and ignored
   files are fine — they get carried over in step 5. `ALLOW_UNPUSHED=1` waives
   the unpushed-commits check; the refs move with `.git` untouched, and every
   ref is additionally saved to `<repo>.pre-worktree.bundle` first.
2. Records the untracked+ignored file list while the index is still readable.
3. Moves the checkout to `<repo>.pre-worktree` and turns its `.git` into the
   bare repo; installs the `post-checkout` hook.
4. Promotes `$SHARED_LOCAL` (default `mise.local.toml`) into `local/`, then
   creates the primary worktree.
5. Copies every remaining untracked/ignored file into the primary worktree,
   minus anything under a `$SKIP_LOCAL` prefix.

Nothing is deleted. Verify, then remove `<repo>.pre-worktree` yourself.

To share more than mise config across worktrees:
`SHARED_LOCAL='mise.local.toml .envrc' migrate-repo.sh ~/work/<repo>`

Step 5 copies ignored build output too, which on a frontend repo is most of the
disk. Leave the regenerable trees behind and rebuild them in the new worktree:
`SKIP_LOCAL='frontend/node_modules frontend/public/static' migrate-repo.sh ~/work/<repo>`

A stash or an unpushed commit trips step 1 even though refs survive the `.git`
move untouched. Don't delete the work to get past it — point a **tag** at it.
Tags live in the common dir, so they survive the move and are visible from every
worktree, and step 1 checks neither tags nor `git stash list` afterwards:

```bash
git tag -a wip/<name> stash@{0} -m 'rescued during worktree migration'
git stash drop                            # content is now reachable via the tag
git stash apply wip/<name>                # later, from any worktree
```

## mise config to check while migrating

- Replace `$PWD` in path env vars with `{{config_root}}`. `$PWD` is the invoking
  directory, so it silently breaks when a task or tool runs from a subdirectory
  (Go tests run with cwd set to the package dir, for example).
- Do not add `dir =` or `[task_config] dir =`. If a config already has
  `dir = "{{cwd}}"`, drop it — `config_root` is now correct.
- Current mise (2026.9+) keeps deps state in `~/.local/state/mise/deps` keyed by
  config path, so worktrees can't collide and no per-repo `.mise/` dir is
  created. An existing `.mise/` with `deps-state.toml`/`prepare-state.toml` is
  leftover from an older mise and can be deleted.

## Verifying a migration

```bash
cd ~/work/<repo>
git worktree list                                   # bare + each worktree
git -C <primary> status --short                     # clean; symlink must not appear
readlink <primary>/mise.local.toml                  # -> ~/work/<repo>/local/mise.local.toml
cd <primary> && mise env | grep -i <a path env var> # resolves under <primary>/
mise run build && mise run test
```

Then check the hook is live (see SKILL.md).

## Gotchas

- Branches with no remote counterpart block migration by design. Push them,
  delete the disposable ones, or run with `ALLOW_UNPUSHED=1` when the work
  must stay local. Check `git for-each-ref` before and after.
- The primary worktree's directory mirrors its branch name. To park a branch
  under a different directory (e.g. `master/` holding a WIP branch), migrate
  with the branch and then `git worktree move <branch-dir> master`; the hook's
  symlinks are absolute, so they survive the move.
