import type { Plugin } from "@opencode-ai/plugin";
import { $ } from "bun";

/**
 * Event types that signal the user's attention is needed.
 */
const NOTIFY_EVENTS = new Set([
  "session.idle",     // generation completed
  "session.error",    // an error occurred
  "permission.asked", // permission needed (tool wants to run)
  "question.asked",   // question tool invoked (user input requested)
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

export const NotifyPlugin: Plugin = async (ctx) => {
  const { client } = ctx
  const command =
    process.env.OPENCODE_NOTIFY_COMMAND?.trim() || DEFAULT_COMMAND

  return {
    event: async ({ event }: { event: Event }): Promise<void> => {
      const runtimeEvent = event as { type: string; properties: Record<string, unknown> }
      if (!NOTIFY_EVENTS.has(runtimeEvent.type)) return

      if (runtimeEvent.type === "session.idle") {
        const activeSession = await client.session.get({ path: { id: runtimeEvent.properties.sessionID } })

        if (activeSession.data?.parentID) {
          // We're in a subagent, don't notify over session.idle
          return
        }
      }

      // fire-and-forget, never block OpenCode
      $`OPENCODE_EVENT=${runtimeEvent.type} sh -c ${command}`
        .quiet()
        .catch(() => { })
    }
  }
}

export default NotifyPlugin;
