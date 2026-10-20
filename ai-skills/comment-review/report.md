# Review-mode report format

Every finding is a **CURRENT / PROPOSAL** pair, so the user can decide without opening the file.

- **Number findings sequentially across the report**, not per file — the user approves by number.
- **CURRENT** quotes the comment verbatim in a fenced block, markers included, without surrounding
  code unless the code makes the verdict obvious.
- **PROPOSAL** is a fenced replacement or the word `delete`. Never implied.
- **One line of reasoning** above the blocks.
- DEDUPE leads in its own section (it's cross-file). Then one section per file, STALE first, the
  rest in line order.

The headline counts every verdict, zeros included, so it's visible each pass ran.

~~~markdown
## Comment review — unstaged changes, 4 files

**10 reviewed · 4 keep · 1 stale · 2 dedupe · 2 cut · 1 trim · 0 rewrite · 1 missing**

### Duplicated rationale

**1. The "htmlUrl over gdata" story is told at four sites.**
Canonical: `internal/feed/parse.go:88`, where the fallback is chosen — keeping.

`internal/feed/entry.go:52`
CURRENT:
```
// YouTube's gdata feed reports the wrong URL for shorts, so we read htmlUrl
// instead. gdata was deprecated in 2015 but the feed still emits it, and the
// value looks plausible, which is why this is easy to get wrong.
```
PROPOSAL: delete

`parse_test.go:31` — `TestPrefersHTMLURL` already names the behaviour.
CURRENT:
```
// gdata reports the wrong URL for shorts, so htmlUrl is preferred.
```
PROPOSAL: delete

`docs/youtube.md:14` — keeping; docs carry the full explanation.

### internal/store/cache.go

**2. `cache.go:48` — STALE.** Says five minutes; `cacheTTL` is now `30 * time.Second`.
CURRENT:
```
// Entries expire after 5 minutes, matching the upstream rate-limit window.
```
PROPOSAL:
```
// Matches the upstream rate-limit window.
```

**3. `cache.go:70-73` — TRIM.** Four lines for one fact; the middle two restate the struct.
CURRENT:
```
// The cache is bounded at 1000 entries. The bound exists because the cache
// holds a map of string keys to entry structs, and callers can request a
// snapshot at any time. Snapshotting copies the entire map, so an unbounded
// cache would make snapshot cost unbounded too.
```
PROPOSAL:
```
// Bounded at 1k entries: the whole map is copied on each snapshot.
```

**4. `cache.go:112` — CUT.** Restates `mu.Lock()` below.
CURRENT:
```
// acquire the lock
```
PROPOSAL: delete

### cmd/serve/main.go

**5. `main.go:34` — CUT.** References the plan, not the code.
CURRENT:
```
// Wire up the phase 2 shutdown handling
```
PROPOSAL: delete

**6. `main.go:71` — MISSING.** The 250ms sleep before `ln.Close()` reads as an unexplained race
workaround. Confirm the reason before applying.
CURRENT: none
PROPOSAL:
```
// Give in-flight handlers time to observe the closed context before the
// listener goes away; without it the readiness probe sees a refused connection.
```
~~~

For a large pass, don't compress by dropping the blocks — split by file instead.

Then stop and ask:

> Apply these? (all / numbers, e.g. "1-3, 5" / verdicts, e.g. "stale+cut")

Edit only after the user answers, and apply exactly what was approved — this is not an opening to
refactor the surrounding code.
