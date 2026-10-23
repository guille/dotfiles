# Explainer mode

You own the content. Nobody presents it: every slide must make sense to
someone clicking through alone.

## 1. Research

- Read the source: the code, docs, diff or material the deck explains. For a
  large codebase, delegate the sweep and keep only the conclusions.
- Note `file:line` (or doc section) for every claim you plan to make. The
  notes will carry them.
- Note anything that looks wrong or surprising along the way. It goes to the
  user in chat, not only onto a slide.

## 2. Outline, for a quick yes

Ask only what you can't decide yourself: the look (see `build.md`) and
density. Show the outline, one line per slide grouped by chapter, in the same
message. Don't iterate on it unless the user wants to.

Plan the visuals as you outline. The patterns that carry an explainer:
- a step-driven component for anything that changes state (a bitmap filling,
  a request flowing, a queue draining), one state change per press;
- `only` or `dim` captions beside a visual, telling the story a speaker
  would;
- `highlight` steps walking through code, with the caption explaining the
  lit lines;
- `section` dividers as chapter breaks, and a `center` slide for the one
  idea the reader must leave with.

## 3. Fact-check before building

Check every slide's claims against the source you noted. For a big deck,
hand the outline and the sources to a subagent to verify. Wrong claims are
easy to write and hard to spot later: an off-by-one in a walkthrough, a
"next slide" that isn't. Fix them before writing HTML.

## Mode rules for the build

- **Self-contained slides:** enough text to read alone, without crowding.
  Cut or split rather than shrink.
- **Notes are sources:** `<aside class="notes">` lists the `file:line`
  references behind the slide's claims.
- **Title slide:** add the navigation hints (arrows to move, `O` overview,
  `F` fullscreen).
- **Order:** go from what it does, to how it works, to the detail the reader
  came for. End on a recap.

## Handover

- Report findings from the research in chat: bugs, gaps, surprising
  behaviour. A finding that only lives on a slide gets missed.
- Say where the deck lives and how to run it.

Now read `build.md`.
