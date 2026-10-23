# Talk mode

The user owns the words and presents them. Your job is the visual side: how
each idea is expressed, what builds and moves, what stays plain. Don't draft
speaker text.

If the user brings an existing deck or outline to polish, skip to the
storyboard with their content as given.

## 1. Discuss the content

Don't write files yet. Talk it through with the user:

- **Audience and setting:** who's watching, where (projector, screen share,
  conference stage), how long the slot is.
- **The one thing** the audience should leave with, and the arc that gets
  them there. Propose an outline, one line per slide, and iterate on it with
  the user.
- **Material they already have:** data, diagrams, code, screenshots, a doc to
  adapt.

## 2. Storyboard the visuals

Once the outline is agreed, propose how each slide is expressed, one line per
slide, tied to the actual content rather than generic:

- step reveals that build an argument point by point (`dim` to keep
  context, `only` for rotating captions, `highlight` to walk through code);
- `section` dividers and `bleed` photos to change the rhythm, and `center`
  slides for a single big number or statement;
- slide transitions (`fade`, `slide`, or a custom one for chapter breaks);
- live components where they earn their place: an animated chart that grows
  step by step, a canvas simulation, a live demo against a backend;
- a backdrop or parallax that ties the deck together.

Offer alternatives where there's a real choice and let the user pick.
Restraint is a valid option: say which slides should stay plain. The user
approves the storyboard separately from the content.

## Mode rules for the build

- **Presenter notes are always exactly `Lorem ipsum`.** Put
  `<aside class="notes">Lorem ipsum</aside>` on every slide. The user writes
  their own notes.
- Slides support a speaker: keep text short, one idea per slide unless the
  user asks for denser reference slides.
- At handover, say that the notes are placeholders for them to fill in.

Now read `build.md`.
