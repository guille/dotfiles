import type { Plugin } from "@opencode-ai/plugin"

const TRASH = process.env.NNN_TRASH ?? "gio trash"

/**
 * OpenCode plugin that replaces "rm foo" with "$NNN_TRASH foo"
 */
export const TrashFilePlugin: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const cmd = (output.args.command as string)?.trim()
      if (!cmd) return
      // Match `rm <files>` with no flags — replace with trash command
      if (/^rm\s+[^-]/.test(cmd)) output.args.command = cmd.replace(/^rm/, TRASH)
    },
  }
}

export default TrashFilePlugin
