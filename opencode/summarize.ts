import type { Plugin } from "@opencode-ai/plugin"
import { writeFileSync, mkdirSync } from "fs"
import { join } from "path"
import { tmpdir } from "os"

const MIN_LINES = 200
const HEAD = 10
const TAIL = 50
const DIR = join(tmpdir(), "opencode-summarized")

/**
 * Plugin that summarizes large bash output to save context tokens.
 *
 * When a bash command produces more than MIN_LINES lines of output,
 * the full output is saved to a file and the LLM receives only the
 * first and last few lines plus a pointer to the full log.
 *
 * Skips output that was already truncated by opencode's built-in
 * truncation, and skips non-bash tools.
 */
export const SummarizePlugin: Plugin = async () => {
  mkdirSync(DIR, { recursive: true })
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool !== "bash") return
      if (output.metadata?.truncated) return
      const text = output.output
      if (!text) return
      const lines = text.split("\n")
      if (lines.length < MIN_LINES) return

      const file = join(DIR, `${input.callID}.log`)
      writeFileSync(file, text)

      const head = lines.slice(0, HEAD).join("\n")
      const tail = lines.slice(-TAIL).join("\n")
      const omitted = lines.length - HEAD - TAIL

      output.output = [
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
      ].join("\n")
    },
  }
}

export default SummarizePlugin
