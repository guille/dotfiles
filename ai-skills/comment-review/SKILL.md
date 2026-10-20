---
name: comment-review
description: Audit code comments for value — cut ones that restate the code, narrate the implementation, reference the conversation or plan that produced them ("implements phase 3", "as requested"), or have drifted out of sync with the code; trim overlong ones; collapse a gotcha explained in five places down to one. Two modes: review (numbered report, then ask) or apply (fix directly, report in one line). Defaults to unstaged changes (git diff); widen to staged, a branch range, a file, or the whole codebase when asked. Use whenever the user asks to review, clean up, audit, trim, deduplicate, or "look over" comments, docstrings, godoc, or docblocks — and when they ask whether a comment is worth keeping, complain that comments are verbose, repetitive, or AI-sounding, ask to strip comments from a diff, or ask to apply comment best practices to their changes — and when another skill says to run it.
---

# Comment Review

One question per comment: **would a competent reader of this code be worse off without it?** If
not, it costs screen space and will rot. Code lives outside time; a comment describing the moment it
was written is already stale.

## Mode

- **Review** — the user asks to review, audit or look over comments, or whether one is worth
  keeping. Report and wait for approval; see [report.md](report.md).
- **Apply** — the user asks to clean up, trim, fix or strip comments, or another skill runs this one.
  Edit directly; no report.

When unclear, review. Both modes run every pass below; only the ending differs.

## Scope

Default: **unstaged changes only.**

```bash
git diff                 # default
git diff --cached        # "staged"
git diff master...HEAD   # "this branch", "my PR"
git diff HEAD            # "everything uncommitted"
```

Review comments on added and modified lines, **plus** pre-existing comments whose subject the diff
touched. Read enough surrounding code to judge; a hunk alone rarely shows whether a comment is
redundant.

Widen only when asked. For a whole-codebase pass, say up front how many files you're covering, then
work and report file by file.

If the diff is empty, say so and ask what to review. Don't silently fall back to the codebase.

Apply mode edits only comments in scope, never the surrounding code.

## Procedure

**Pass 1 — Enumerate.** List every comment in scope with its `path:line` before judging any.

**Pass 2 — Judge each comment.** Run these in order; the first hit is the verdict:

1. Contradicts the code it sits next to? → **STALE**
2. Not anchored to code that exists — floating between unrelated declarations, or describing
   something absent (a removed function, a rejected feature)? → **CUT**, however accurate. See
   *Talks about absent code*.
3. Any noun that doesn't resolve using only the repository? → **CUT**. See *Addressed to the
   conversation*.
4. Derivable from the code by a competent reader? → **CUT**
5. Required by the language (godoc, public docstring) but adds nothing beyond the signature?
   → **REWRITE**
6. Could say the same in meaningfully fewer words, or longer than the code it describes? → **TRIM**.
   Run it on every comment: overlong ones are usually correct, so nothing else flags them.
7. Otherwise **KEEP** — but only if you can say in six words what a reader loses without it. If you
   can't, revisit 4 and 6.

**Pass 3 — Cluster.** Group the survivors by *the fact each conveys*. Any fact stated at two or more
sites goes to *Say it once*. This catches comments that are individually fine and collectively
redundant.

**Pass 4 — Finish.**

- *Review:* report per [report.md](report.md), then stop and ask.
- *Apply:* make the edits. CUT, DEDUPE and TRIM always; REWRITE when the intent is clear from the
  code; STALE when the code shows the correct fact. Don't apply MISSING or a STALE whose correct fact
  you can't confirm — writing a *why* you had to guess is the defect this skill removes. End with
  one line of counts, the canonical site of each DEDUPE, and those leftovers, e.g.:
  `Comments: 14 reviewed · cut 4 · trim 2 · dedupe 1 (kept parse.go:88) · 1 open: main.go:71 MISSING, why the 250ms sleep?`

**Calibration.** More than a handful of LLM-authored comments with zero findings is unlikely —
verbosity and repetition are that prose's default. If you land on "clean," re-run tests 2, 4, 6 and
Pass 3 explicitly. Don't manufacture findings either; just reach "clean" by applying the tests.

## Verdicts

| Verdict | Meaning | Action |
|---|---|---|
| **STALE** | Contradicts the code. Always flag first. | Correct it |
| **CUT** | Says nothing the code doesn't, or nothing that resolves in the repo. | Delete |
| **DEDUPE** | True and useful, but stated elsewhere. | Delete |
| **TRIM** | Right content, too many words. Deleting words keeps the message. | Supply shorter version |
| **REWRITE** | Intent worth keeping; the text says the wrong thing or nothing. | Supply replacement |
| **MISSING** | Non-obvious code with no explanation. | Supply the comment |
| **KEEP** | Earns its place; you can name the loss. | None |

Be conservative with MISSING: raise it only where you had to stop and reconstruct *why*.

## The dominant failure mode

Most comments you review were written by an LLM. A model writes to show it understood
the task; the reader wants only what they can't derive. Judge without deference to prior effort.

**1. Addressed to the conversation.** References a plan, step, request, or prior turn.
```go
// This method implements phase 3 of the refactor
// As requested, validate the payload before dispatch
// Helper for the new caching layer
// Note: this handles the edge case discussed above
```
Always CUT; there's nothing to rewrite. Exception: a numbered algorithm whose steps are in the code.
The trap: when reviewing your own code in the same session, "phase 3" still resolves *for you*.
Judge as someone with the repository and nothing else.

**2. Talks about absent code.** A paragraph justifying why something *doesn't* exist, sitting on
nothing. Its facts usually check out, so it reads as diligence. The tell is the subject: history, not
the file as it stands. Always CUT.
```go
// There is no bulk EnableFeed. Feeds only die one at a time: error_count
// moves solely in RecordFetch's error branch...
```
Contrast a *rejected alternative* comment (KEEP), which sits on the code embodying the choice made.

## Say it once

A real gotcha tempts a warning everywhere it's relevant: the call site, the test, the helper, the
docs. Each is defensible; together they're a defect — N times the reading cost, they drift apart,
and readers stop reading the repeats.

Keep one full explanation at the **canonical site**, preferring:

1. **Where the trap is sprung** — the line that would be wrong without the fact. Usually production
   code, not the test.
2. **The definition or enforcement point** over its call sites.
3. **The narrower scope** — one package doc over the same note on four methods.

Everything else gets deleted. Use a pointer only with a strong reason.

**Tests** usually need nothing: `TestPrefersHTMLURLOverGData` already said it. If one needs a
comment, it names the scenario, not the rationale.

**Prose docs** are a separate audience and may restate a code comment: docs carry the full
explanation, code the short version. Don't DEDUPE a docs paragraph for overlapping a code comment.

Always name the canonical site in a DEDUPE finding, so the user approves a consolidation, not a bare
deletion.

## What to cut

- **Restates the code**, including a narrating comment on every block.
- **Narrates the change** (`Previously we used a list…`, `NEW: added retry`): that's the commit
  message.
- **Unaccountable TODOs**: give it an owner and issue link, or cut it.

## What to keep

Why, not what; constraints and invariants; traps the next person would fall into; rejected
alternatives, on the code that embodies the choice; workarounds, always with a reference (bug link,
version).

## Judgment calls

- **Right comment, unclear code.** Suggest the rename or extraction that makes it unnecessary; don't
  make it unless asked.
- **Audience.** A comment you'd cut in app code may be load-bearing in a public library or build
  script.
- **Not for taste.** A clumsy comment carrying real information is KEEP. If your TRIM isn't clearly
  shorter, leave it.
