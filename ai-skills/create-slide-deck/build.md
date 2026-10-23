# Look, build and check

Shared by both modes.

## 1. Confirm the look

Before building, agree on the look explicitly:

- mood and palette (light/dark, brand colors, logos, accent), fonts for
  headings, body and code;
- density (one idea per slide vs. denser reference slides);
- transitions and motion level;
- setup (vanilla with no build is the default; pick a framework only for what
  the library README says it adds).

For a work (Nearby Computing) deck, offer these choices, then copy
`~/work/slides-middleware/nearby/` next to `lib/` and follow its README:
- **template** (`template.css`): follows the corporate PPTX template. Pick it
  when the deck sits next to PowerPoint slides or goes to customers.
- **brand, open style:** the Nearby palette (`brand.css`), with the look left
  open. `blueprint.css` is a ready-made dark theme. Or propose two or three
  directions built on `brand.css`, each one a few `--deck-*` tokens plus a
  sentence on the feel. This is the default for explainers and internal decks.
- **off-brand:** skip the middleware and use the directions below.

Otherwise, offer two or three short theme directions, each one a few
`--deck-*` tokens plus a sentence on the feel. If the user leaves the choice
to you, pick one and say which. Don't start building until the look is
settled.

## 2. Build

- **Where it lives:** outside any git worktree unless the user says
  otherwise, so the deck never shows up as untracked files. In a bare-repo
  layout, a sibling of the worktrees works (`~/work/<repo>/<deck>/`).
- **Vendor the library into the deck's own folder.** Copy `deck.js`,
  `deck.css`, `presenter.js` (and `index.d.ts` + `types/` for TypeScript
  setups) from `~/projects/slides/lib/` into a `lib/` directory inside the
  deck folder, and import from there. Don't reference the source repo by path
  or modify the original. The deck must keep working if the library changes
  later.
- Theme through the `--deck-*` custom properties in your own unlayered CSS,
  as the library README describes. A shared theme sits in `@layer
  deck.theme`, below the library's `deck.core` layer: it can't override what
  `deck.core` sets on `html` and `body`, so design around those rules instead
  of fighting them.
- Author at 1920×1080. Overflow is a bug: split the slide or cut the text
  instead of shrinking it.
- Grid and flex items split mixed inline content: `<li>` with
  `display: grid` and `<b>text</b> more text` becomes several grid items.
  Wrap the text in one element.

## 3. Check before handing over

- **No console warnings.** The runtime warns `deck: slide N overflows the
  stage` and about clipped `<pre>` blocks. Collect them with a headless page
  load stepped to the end of every slide (`#N.99`), not by eye.
- Let the user drive visual QA: their feedback loop is faster and more
  accurate than screenshots.
- For decks with components or heavy effects, run the profiler included in
  the `performant-slides` skill.
- Tell the user how to run it and how to export a PDF.
