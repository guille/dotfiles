---
name: nag-me
description: Leave the user a persistent nag (via the `nag` CLI) when something needs their decision or action and they may not be watching — in loops, background or long unattended work — so it isn't lost among routine messages. Covers key naming (prefixed by harness: `claude.` or `opencode.`), the body format, checking what's still open, and acking once the user answers or the issue resolves itself. Use when a loop, watcher or background task hits something only the user can decide, when the user says "nag me", or when a skill or loop file says to notify the user.
---

# Nag me

`nag` is the user's persistent to-do queue; the count of pending nags shows in their shell prompt.
A nag is for something that needs **the user's decision or action** and would otherwise be lost —
typically raised from a loop or unattended work. Routine status ("nothing new this tick", "CI still
running") is never a nag. No desktop notifications or sounds: the prompt count is the signal.

The user also uses `nag` for other things. **Only ever create, update or ack keys starting with
`claude.` or `opencode.`**, and raise yours under your own harness's prefix.

## Keys

`<harness>.<source>.<event>`, where `<harness>` is `claude` or `opencode`. `<source>` is the loop
or skill name (eg `pr-watch`), or the repo for ad-hoc work (`myrepo`). `<event>` identifies one
event, not an ongoing condition, so an acked nag doesn't come back: `claude.pr-watch.pr42-review`
or `opencode.myrepo.pr36-merge`, not `opencode.myrepo.ci-red`. Keys match
`^[A-Za-z][A-Za-z0-9_.@-]*$`.

## Raising one

Check it isn't already open (`nag ls`, third column is the key), then:

```bash
nag add -k <harness>.<source>.<event> '<one-line summary>' - <<'EOF'
What: <what happened, one or two lines>
Why you: <the decision or action only the user can take>
Link: <PR / Slack message / issue / file>
Suggested: <what you'd do, if you have a view>
Reply in: <this session's name>, <cwd>
EOF
```

This session's name comes from `ListAgents` ("This session is …") in Claude Code, or
`agents_whoami` in Opencode.

Re-adding the same key replaces the body and keeps its age: use that to update an open nag with
new information instead of adding another.

Loops with a state file: record the keys they've raised, so they can tell later whether a missing
key was acked by them or dismissed by the user.

## Lifecycle

- **The user answers you** with a decision about a nag → record or act on the decision, then
  `nag ack <key>`. Ack once you have the decision, not when the follow-up work finishes. If that
  work later fails, that's a new event with a new key.
- **It resolves without the user** (the request is withdrawn, the PR got merged by someone else) →
  `nag ack <key>` and say so in your output.
- **A key you raised is gone and you didn't ack it** → the user dismissed it. Don't raise it
  again.
- **At the start of each loop tick**, `nag ls` and mention any of this source's nags still open in one
  line, so the user sees what's waiting without opening the queue.
