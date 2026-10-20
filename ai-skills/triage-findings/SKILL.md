---
name: triage-findings
description: Triage review findings on the user's own code — review comments on one of their open PRs, or a list of findings they paste in (from a teammate, another session, a tool, a subagent's report). Gives each a numbered verdict (valid? worth it? cleanest fix? contradicts an earlier decision?), then either waits for approval by number (pasted findings) or applies the clear-cut ones and escalates the rest (PR comments), and tracks what's solved, pending or newly introduced across rounds. Use when the user asks to check or address PR comments, pastes findings, asks "valid?", "worth addressing?", "walk me through this one", approves findings by number ("do 1-4", "approved 1, 3, 5"), or asks for a solved/pending summary. Not for producing a review, and not for reviewing other people's PRs.
---

# Triage findings

Input: findings someone else produced about the user's code. This skill doesn't generate a review;
it judges one.

The loop: **collect → verdicts → decide → apply.** Who decides depends on the mode:

| Mode | Default for | Decide step |
|---|---|---|
| **Gated** | Pasted findings | The user approves by number. Nothing is applied before that. |
| **Autopilot** | Comments on the user's PR | Apply what's clearly right; escalate the rest. |

The user can switch modes at any time ("just handle it", "check with me first").

## 1. Collect

| Source | How |
|---|---|
| The user's open PR | `<skill-dir>/scripts/pr-threads.sh [pr]` prints review summaries, conversation and unresolved threads (`--all` includes resolved). No argument means the current branch's PR. |
| Pasted list, or a report already in the conversation | Take it as given. When findings arrive one at a time, verdict each as it arrives. |

Before judging, read the project's decision records: DESIGN.md, HANDOFF*.md, PROPOSAL.md, ADRs, the
linked issue. A finding that re-opens a settled decision is a different kind of finding.

**Number findings once** (#1, #2, …) and keep those numbers for the rest of the conversation. If the
source already numbers them, keep its numbers. Later rounds continue the sequence; never renumber.

## 2. Verdicts

Every finding gets the same four questions, whoever raised it. Teammates, tools and subagents are
not gospel.

1. **Valid?** Check it against the current code and quote the line. Pasted findings may come from
   another session or an older revision. If reading the code can't confirm it, say so.
2. **Worth it?** Weigh the gain against the cost. Complexity is justified by a big gain, not a
   minor one. A test that only exercises the stdlib, or defensive code for an impossible case,
   isn't worth it.
3. **Cleanest fix?** Their suggested fix, or a better one. Prefer the right design over a
   tape-over.
4. **Conflicts?** Does it contradict a decision recorded in those docs? Name the decision.

Read-only while judging: don't run tests, builds or experiments unless the user asks.

Present as one compact table, then only the detail that matters:

| # | Finding | Verdict | Recommendation |
|---|---|---|---|
| 1 | Null `min` renders `<nil>` (`range_test.go:210`) | Valid, cheap | Fix as suggested |
| 2 | Expose `missing` | Valid, minor | Skip for now |

Use plain and simple but technically accurate language.
Lead with which numbers you'd do. No walls of text; offer to walk through any one in depth.

## 3. Decide

**Gated.** Stop after the verdicts. No edits until the user approves by number ("do 1-4",
"approved 1, 2, 11"). Partial approvals are normal while the user is still reading; unapproved
numbers stay pending. Questions about a finding ("walk me through #3", "is that the cleanest?") are
discussion, not approval.

**Autopilot.** Apply findings that are valid, worth it, and have an obvious clean fix, without
asking. Escalate, and leave pending, anything that:

- you'd reject or only partly accept, since the reviewer will need an answer;
- needs a design call, or a fix noticeably bigger than the comment implies;
- conflicts with a recorded decision.

Show the table first anyway, marking which numbers you're applying, so the user can veto before
reading the diff.

## 4. Apply

- Only the approved numbers (gated) or the ones marked for applying (autopilot). Nothing adjacent
  "while you're there"; raise it as a new finding instead.
- Smallest clean fix per number. If a fix turns out bigger than its verdict suggested, stop and say
  so before continuing.
- Run the relevant `mise run` checks for what you touched.
- Run the `comment-review` skill in apply mode over your own changes before reporting: fixes tend
  to sprout narrating comments.
- Report per number, in a line each: done, or why not.

Fixes stay local in both modes. Commit and push only if and when the user asks to. Even then, first say what
will happen (which commit the fixes are amended or squashed into, which branch) and get a yes.
Then amend and run `git push --force-with-lease`; don't add a new commit unless asked to. When asked to update the PR
description, edit or remove only what's outdated; never rewrite it.

Hint: for repos under ~/work the user tends to let you commit and push, for repos under ~/projects you will almost never commit or push.

## Status across rounds

Keep the ledger in the conversation (no file unless the user asks): each number is pending,
approved, done, or skipped. For PRs, remember the head SHA at the last round.

On "status?", "where are we", "new commits + comments": re-collect from
the source, diff against the last head SHA, and report three buckets:

- **Solved**: by number, one line each.
- **Still pending**: by number, with what's blocking.
- **New**: newly raised or introduced by the latest changes, continuing the numbering.
