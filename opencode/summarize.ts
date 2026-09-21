import { Plugin } from "@opencode/plugin"
import { writeFileSync, mkdirSync } from "node:fs"
import { join } from "node:path"
import { tmpdir } from "node:os"

const MIN_LINES = 200
const HEAD = 10
const TAIL = 50
const DIR = join(tmpdir(), "opencode-summarized")

/**
 * Plugin that summarizes large shell output to save context tokens.
 *
 * When a shell command produces more than MIN_LINES lines of output,
 * the full output is saved to a file and the LLM receives only the
 * first and last few lines plus a pointer to the full log.
 *
 * Skips output that was already truncated by opencode's built-in
 * truncation, and skips non-shell tools.
 */
export default Plugin.define({
  id: "summarize",
  setup: async (ctx) => {
    mkdirSync(DIR, { recursive: true })

    await ctx.tool.hook("execute.after", (event) => {
      if (event.tool !== "shell") return
      if (event.status !== "completed") return
      if (event.result.metadata?.truncated) return

      const content = event.result.content
      const text =
        typeof content === "string"
          ? content
          : (content ?? []).flatMap((item) => (item.type === "text" ? [item.text] : [])).join("\n")
      if (!text) return
      const lines = text.split("\n")
      if (lines.length < MIN_LINES) return

      const file = join(DIR, `${event.id}.log`)
      writeFileSync(file, text)

      const head = lines.slice(0, HEAD).join("\n")
      const tail = lines.slice(-TAIL).join("\n")
      const omitted = lines.length - HEAD - TAIL

      event.result = {
        ...event.result,
        content: [
          `=== First ${HEAD} lines ===`,
          head,
          ``,
          `... ${omitted} lines omitted ...`,
          ``,
          `=== Last ${TAIL} lines ===`,
          tail,
          ``,
          `Full output (${lines.length} lines) saved to: ${file}`,
          `Use Read with offset/limit or Grep to inspect it.`,
        ].join("\n"),
      }
    })
  },
})
