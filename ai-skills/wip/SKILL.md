---
name: wip
description: Track the user's parallel workstreams with the `wip` CLI — log milestones, update status, mark items waiting on someone, close them, and produce standup summaries. Use when a SessionStart message says the directory belongs to a workstream, when the user says "track this", asks what's open/waiting/blocked, asks for a standup or "what did I do since X", or when work on a tracked workstream reaches a milestone, a handoff or a finish.
---

`wip` tracks workstreams: units of work roughly the size of a PR up to an epic, not individual tasks. Each is a Markdown file under `~/.local/share/wip`. **Only change them through the CLI** — it validates every write. `wip help` lists all commands.

## When the session starts inside a workstream

The SessionStart hook prints the workstream(s) bound to this directory. Read the `doc` it names before starting work if there is one. If it says `waiting on me`, the user is probably here to answer that — once they have, record the answer with `wip log`, which also moves the item back to active.

## Creating

Create a workstream **only when the user asks** ("track this", "make a workstream for…"). Never create one per task or subtask. Bind it to where the work happens:

```sh
wip new "Short descriptive title" --scope work --here      [--issue URL] [--doc PATH]  # branch work: this worktree
wip new "Short descriptive title" --scope work --here-repo [--issue URL] [--doc PATH]  # not tied to a branch yet: the whole repo
```

Both record the repo name too. An item bound with `--here-repo` shows up in every worktree of the repo; when it gets a branch, add `wip set ID --here`. Repo names are plain (`orbit`, not `guille/orbit`).

Scope is always `work` or `personal`: `work` for anything under `~/work`, `personal` otherwise; ask if unsure.

## Updating

| When | Command |
|---|---|
| A milestone the user would mention in standup (PR opened, approach decided, bug root-caused, merged) | `wip log ID "one line"` |
| The one-line "where is it at" changes | `wip status ID "≤80 chars"` |
| You opened a PR or asked someone for something, and the work can't move until they act | `wip wait ID <who> "reason"` |
| The session is ending on a decision only the user can make (proposal written, approach A vs B) | `wip wait ID me "what you need from them"` |
| Something outside the work is in the way | `wip block ID "text"` / `wip unblock ID [N]` |
| Merged or shipped / abandoned | `wip done ID ["note"]` / `wip drop ID ["why"]` |

Rules:

- **Log milestones, not steps.** "ran tests", "edited foo.go" and "investigating" are not log entries. Zero entries in a session is normal.
- **Don't mark `waiting on me` just because your turn ended.** Use it only for durable waits that will outlive this session.
- `wip log` and `wip status` resume a waiting item automatically. Doing work on a waiting item is what ends the wait.
- If the user asks you to nag them, nag and `wip wait ID me …` are separate and both apply.
- Use `wip set` for field changes (`--doc`, `--issue`, `--link`, `--path`, `--here`, `--here-repo`, `--repo`, `--title`). Never use `wip edit` (it opens an editor) and never edit the files directly.

## Answering questions

- What's open: `wip ls [--scope work|personal] [--repo NAME]`
- Waiting on the user / on others: `wip ls --waiting me` / `wip ls --waiting others`
- Recently finished: `wip ls --state done`
- Details: `wip show ID`

## Standup

Run `wip report --since <when> --scope work` (`<when>` is a date, `mon`..`sun`, `yesterday` or `3d`; it defaults to `mon`). Summarize it per workstream: what moved, what's waiting and on whom, what's blocked. Keep it short and don't invent detail beyond the log.
