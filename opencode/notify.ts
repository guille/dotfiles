import { Plugin } from "@opencode/plugin"
import { spawn } from "node:child_process"

/**
 * Event types that signal the user's attention is needed.
 */
const NOTIFY_EVENTS = new Set([
  "session.idle",             // generation completed
  "session.execution.failed", // an error occurred
  "permission.asked",         // permission needed (tool wants to run)
  "form.created",             // question tool invoked (user input requested)
])

/**
 * OpenCode plugin that executes a user-configured command whenever
 * an event requiring user attention is fired.
 *
 * Set `OPENCODE_NOTIFY_COMMAND` to the command to run.
 * The event type is passed as the `OPENCODE_EVENT` environment variable.
 *
 * Example:
 *   OPENCODE_NOTIFY_COMMAND="notify-send 'OpenCode' '$OPENCODE_EVENT'"
 */
const DEFAULT_COMMAND = `notify-send -i org.gnome.Robots "OpenCode" "Waiting for user ($OPENCODE_EVENT)"`

export default Plugin.define({
  id: "notify",
  setup: async (ctx) => {
    const command = process.env.OPENCODE_NOTIFY_COMMAND?.trim() || DEFAULT_COMMAND
    const controller = new AbortController()

    // fire-and-forget, never block OpenCode
    const notify = (type: string) =>
      spawn("sh", ["-c", command], {
        env: { ...process.env, OPENCODE_EVENT: type },
        stdio: "ignore",
        detached: true,
      })
        .on("error", () => {})
        .unref()

    const pump = async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        if (!NOTIFY_EVENTS.has(event.type)) continue

        if (event.type === "session.idle") {
          const session = await ctx.session.get({ sessionID: event.data.sessionID })
          // We're in a subagent, don't notify over session.idle
          if (session.parentID) continue
        }

        notify(event.type)
      }
    }

    void pump().catch(() => {})

    return () => controller.abort()
  },
})
