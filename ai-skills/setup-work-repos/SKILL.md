---
name: setup-work-repos
description: One-time setup of a repo under ~/work into the bare-repo + worktree layout — migrating an existing plain checkout, or cloning a new repo straight into the structure. Use when asked to migrate/convert a repo to worktrees, set up a new repo in the worktree layout, clone something into ~/work, or fix a worktree repo whose shared mise config or post-checkout hook is missing. Not for day-to-day worktree use (adding a branch worktree in an already-converted repo needs no help — plain `git worktree add` suffices).
---

# Setting up ~/work repos as bare + worktrees

To migrate an existing plain checkout, read [migrate.md](migrate.md) as well. `<skill-dir>` below is
this skill's base directory.

## Target layout

```
~/work/<repo>/
  .git/                              bare repo (core.bare=true)
  local/                             untracked config shared by ALL worktrees
    mise.local.toml
  master/                            worktree for master
    mise.local.toml -> ../local/mise.local.toml     (created by the hook)
  feature/foo/                       worktree; dir mirrors the branch name
    mise.local.toml -> ../../local/mise.local.toml
```

Worktree directories mirror branch names, so `feature/foo` is two levels
deep. This is intentional: the branch↔directory mapping stays unambiguous, and
git already forbids a branch `feature` coexisting with `feature/foo`, so
the directory tree can never collide either.

`.git` is a plain bare *directory*. The `.bare` directory plus a `.git` file
pointing at it (as some blog posts do) is unnecessary — git discovers a bare
`.git` from the repo root, so `git fetch`, `git branch`, `git worktree add` and
`git log` all work from `~/work/<repo>`. Only `git status` there fails with
"this operation must be run in a work tree", which is harmless and expected.

A personal, repo-scoped `CLAUDE.md` goes at the **repo root**, beside `.git/`
and `local/` — e.g. `~/work/<repo>/CLAUDE.md`.

## Cloning a new repo into the structure

```bash
cd ~/work && <skill-dir>/scripts/clone-repo.sh <git-url> [dir] [primary-branch]
```

Then drop shared config into `<repo>/local/` and run `git checkout <primary>`
inside the primary worktree to link it.

This uses `git init --bare` + `remote add` + `fetch`, **not** `git clone --bare`.
A bare clone dumps every remote branch into `refs/heads/*` and sets no fetch
refspec, so `git branch` becomes a wall of noise and `git worktree add <branch>`
cannot DWIM a tracking branch.

## How the shared config works, and why it must be a symlink

`.git/hooks/post-checkout` mirrors the `local/` tree into the worktree as
symlinks. It fires on `git worktree add` (cwd is the new worktree) and on every
`git checkout`, so it is self-installing and self-healing — nobody, human or
agent, has to remember a step. It cd's to `git rev-parse --show-toplevel` first,
because `git checkout` can be run from a subdirectory.

The obvious alternative — one `mise.local.toml` at `~/work/<repo>/` picked up by
mise's parent-directory search — **does not work**. mise resolves everything
relative to the directory holding the config file: default task dir,
`{{config_root}}`, `exec()`, `[env] _.source`. So tasks would run in
`~/work/<repo>/`, which holds no code. `{{cwd}}` is mise's only handle on the
invoking directory, and `[task_config] dir = "{{cwd}}"` only helps when you are
exactly at the worktree root — from `master/pkg/foo` it silently anchors tasks
and path env vars to `pkg/foo`. `env_shell_expand = true` expands `$VAR` but not
`$(...)`, so command substitution can't recover the root either.

mise does *not* resolve the symlink when deciding which directory a config
belongs to. A symlinked `mise.local.toml` therefore makes `config_root` the
worktree root, and existing configs work verbatim — no `dir`, no `{{cwd}}`,
correct from any depth.

Check the hook is live after any setup:

```bash
git worktree add feat/probe -b feat/probe --no-track <primary>
[ -L feat/probe/mise.local.toml ] && echo hook OK
git worktree remove feat/probe && git branch -D feat/probe && rmdir feat
```

## Repairing an already-converted repo

Missing hook, or worktrees created before it existed:

```bash
install -m 755 <skill-dir>/scripts/post-checkout \
  ~/work/<repo>/.git/hooks/post-checkout
# then, in each worktree, any checkout re-links:
git -C ~/work/<repo>/<worktree> checkout HEAD -- . 2>/dev/null || \
  git -C ~/work/<repo>/<worktree> checkout "$(git -C ~/work/<repo>/<worktree> branch --show-current)"
```

## Gotchas

- `git worktree remove feature/x` leaves the now-empty parent `feature/` behind.
  Follow with `rmdir -p --ignore-fail-on-non-empty feature`.
- New branches should be created `--no-track` so they don't inherit master's
  upstream: `git worktree add feat/x -b feat/x --no-track master`. Checking out
  an *existing* remote branch of the same name is different and should track:
  `git worktree add feature/x feature/x` DWIMs to `origin/feature/x` correctly.
- `mise.local.toml` is in the user's global gitignore, so the symlink never
  shows up as untracked. A shared file *not* covered by an ignore rule would —
  check before adding one to `local/`.
- Keep editor state **out** of `local/`. `*.sublime-project` and
  `*.sublime-workspace` belong in the primary worktree only — Sublime writes the
  workspace next to the project file, so sharing it makes worktrees fight over
  editor state.
