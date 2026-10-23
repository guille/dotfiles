---
name: create-slide-deck
description: Create a new presentation / slide deck / talk with the `deck` library (in ~/projects/slides/lib). Talks content through with the user first, pitches animations and visual ideas, confirms style and theme, then builds the deck with the library vendored into the deck's own folder.
disable-model-invocation: true
---

# Create a slide deck

The library lives at `~/projects/slides/lib/`. **Read
`~/projects/slides/lib/README.md` in full before writing
anything.** It is the authoring contract: layouts, steps and effects,
persistent chrome, theming tokens, transitions, `onSlide` components, PDF
export, and which setup (vanilla, Astro, Svelte, Lit, htmx) fits which deck.
The demos under `~/projects/slides/demos/` are reference
implementations of each setup; borrow patterns from them.

Also load the `performant-slides` skill before writing effects, transitions or
components.

## 1. Discuss the content first

Don't write files yet. Talk it through with the user:

- **Audience and setting:** who's watching, where (projector, screen share,
  conference stage), how long the slot is.
- **The one thing** the audience should leave with, and the arc that gets
  them there. Propose an outline, one line per slide, and iterate on it with the
  user.
- **Material they already have:** data, diagrams, code, screenshots, a doc to
  adapt.

Then **pitch how to make it visually impactful**, tied to their actual
content rather than generic:
- step reveals that build an argument point by point (`dim` to keep
  context, `only` for rotating captions, `highlight` to walk through code);
- `section` dividers and `bleed` photos to change the rhythm, and `center`
  slides for a single big number or statement;
- slide transitions (`fade`, `slide`, or a custom one for chapter breaks);
- live components where they earn their place: an animated chart that grows
  step by step, a canvas simulation, a live demo against a backend;
- a backdrop or parallax that ties the deck together.

Suggest a few concrete ideas per section and let the user pick. Restraint is a
valid option: say which slides should stay plain.

## 2. Confirm style and theme

Before building, agree on the look explicitly:

- mood and palette (light/dark, brand colors, logos, accent), fonts for headings,
  body and code;
- density (one idea per slide vs. denser reference slides);
- transitions and motion level;
- setup (vanilla with no build is the default; pick a framework only for what
  the README says it adds).

For a work (Nearby Computing) deck, ask whether to use the house theme: copy
`~/work/slides-middleware/nearby/` next to `lib/` and follow its
README instead of proposing a palette.

Otherwise, offer two or three short theme directions, each one a few `--deck-*` tokens
plus a sentence on the feel, and wait for the user's choice. Don't start
building until they've confirmed.

## 3. Build

- **Vendor the library into the deck's own folder.** Copy `deck.js`,
  `deck.css`, `presenter.js` (and `index.d.ts` + `types/` for TypeScript
  setups) from `~/projects/slides/lib/` into a `lib/` directory
  inside the folder you're working in, and import from there. Don't reference
  the source repo by path or modify the original. The deck must keep working
  if the library changes later.
- Theme through the `--deck-*` custom properties in your own unlayered CSS,
  as the README describes.
- **Presenter notes are always exactly `Lorem ipsum`.** Put
  `<aside class="notes">Lorem ipsum</aside>` on every slide. The user writes
  their own notes; don't draft speaker text.
- Author at 1920×1080. Overflow is a bug: split the slide or cut the text
  instead of shrinking it.

## 4. Check before handing over

- No console warnings: the runtime warns `deck: slide N overflows the stage`.
- Let the user drive QA: the feedback loop is faster and more accurate than Playwright.
- For decks with components or heavy effects, run the profiler included in the `performant-slides`
  skill.
- Tell the user how to run it, how to export a PDF, and that the notes are
  placeholders for them to fill in.
