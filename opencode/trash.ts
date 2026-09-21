import { Plugin } from "@opencode/plugin"

const TRASH = process.env.NNN_TRASH ?? "gio trash"

/**
 * OpenCode plugin that replaces "rm foo" with "$NNN_TRASH foo"
 */
export default Plugin.define({
  id: "trash",
  setup: async (ctx) => {
    await ctx.shell.hook("create.before", (event) => {
      const cmd = event.command.trim()
      if (!cmd) return
      // Match `rm <files>` with no flags — replace with trash command
      if (/^rm\s+[^-]/.test(cmd)) event.command = cmd.replace(/^rm/, TRASH)
    })
  },
})
