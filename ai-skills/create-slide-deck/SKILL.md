---
name: create-slide-deck
description: Create a slide deck with the `deck` library (in ~/projects/slides/lib), in one of two modes. Talk: the user owns the content and presents it; the agent designs visuals, builds and transitions. Explainer: the agent researches and writes a self-contained deck people read alone. Then confirms the look and builds with the library vendored into the deck's own folder.
disable-model-invocation: true
---

# Create a slide deck

## Pick the mode first

Two questions decide everything else:

1. **Who owns the content?** The user, or you.
2. **How is it consumed?** Presented live, or read alone.

Take the mode from the arguments when they name it (`talk`, `explainer`, or
wording like "I'll present", "explain X to me"). Otherwise ask both questions
in one prompt. Then **read only the matching file**, next to this one in the
skill's base directory:

| Mode          | When                                    | Read             |
| ------------- | --------------------------------------- | ---------------- |
| **talk**      | the user writes it and presents it      | `talk.md`        |
| **explainer** | you write it, people read it alone      | `explainer.md`   |

The other two combinations:
- **The user's doc or notes, turned into a read-alone deck:** use
  `explainer.md`, with their material as the only source.
- **A talk you draft for the user to present:** use `talk.md`, but you may
  draft the slide text. The notes stay `Lorem ipsum`.

After the mode's content phase, read `build.md` for the look, the build and
the checks. It applies to both modes.

## Always

- **Read `~/projects/slides/lib/README.md` in full before writing anything.**
  It is the authoring contract: layouts, steps and effects, persistent
  chrome, theming tokens, transitions, `onSlide` components, PDF export, and
  which setup (vanilla, Astro, Svelte, Lit, htmx) fits which deck. The demos
  under `~/projects/slides/demos/` are reference implementations of each
  setup; borrow patterns from them.
- Load the `performant-slides` skill before writing effects, transitions or
  components.
