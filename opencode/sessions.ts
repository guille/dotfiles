import { Plugin } from "@opencode/plugin"
import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import path from "node:path"

type Registration = { url: string; password?: string }

type SessionInfo = {
  id: string
  parentID?: string
  agent?: string
  title?: string
  location: { directory: string }
  time: { updated: number }
}

// The plugin session domain has no list/active, so ask the local service directly.
async function api<T>(route: string, signal: AbortSignal): Promise<T> {
  const state = process.env.XDG_STATE_HOME ?? path.join(homedir(), ".local", "state")
  const service = JSON.parse(await readFile(path.join(state, "opencode", "service.json"), "utf8")) as Registration
  const headers =
    service.password === undefined ? undefined : { authorization: "Basic " + btoa(`opencode:${service.password}`) }
  const response = await fetch(new URL(route, service.url), { headers, signal })
  if (!response.ok) throw new Error(`GET ${route}: ${response.status} ${await response.text()}`)
  return (await response.json()) as T
}

export default Plugin.define({
  id: "sessions",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.namespace({
        name: "agents",
        description: "Discover other opencode sessions (agents) and message them",
      })

      editor.add({
        name: "whoami",
        description: "Return the current session ID",
        input: { type: "object", properties: {}, additionalProperties: false },
        options: { namespace: "agents", codemode: true, pinned: true },
        execute: async (_, context) => ({ content: context.sessionID }),
      })

      editor.add({
        name: "list",
        description:
          "List opencode sessions in this project, most recently updated first: id, running/idle, agent, title. '*' marks the caller; subagents show their parent.",
        input: {
          type: "object",
          properties: {
            all: { type: "boolean", description: "Include sessions from every project" },
            limit: { type: "integer", minimum: 1, maximum: 200, description: "Defaults to 50" },
          },
          additionalProperties: false,
        },
        options: { namespace: "agents", codemode: true, pinned: true },
        execute: async (input, context) => {
          const { all, limit } = input as { all?: boolean; limit?: number }
          const query = new URLSearchParams({ order: "desc", limit: String(limit ?? 50) })
          if (!all) query.set("project", ctx.location.project.id)
          const [sessions, active] = await Promise.all([
            api<{ data: SessionInfo[] }>(`/api/session?${query}`, context.signal),
            api<{ data: Record<string, unknown> }>("/api/session/active", context.signal),
          ])
          const lines = sessions.data.map((s) =>
            [
              s.id === context.sessionID ? "*" : " ",
              s.id,
              s.id in active.data ? "running" : "idle",
              s.agent ?? "-",
              s.title ?? "(untitled)",
              s.parentID ? `child of ${s.parentID}` : "",
              all ? s.location.directory : "",
            ]
              .filter(Boolean)
              .join("  "),
          )
          return { content: lines.join("\n") || "No sessions." }
        },
      })

      editor.add({
        name: "send",
        description:
          "Send a message to another session's inbox. Returns immediately; the target handles it on its next turn ('queue') or at its next safe boundary ('steer').",
        input: {
          type: "object",
          properties: {
            sessionID: { type: "string" },
            text: { type: "string" },
            delivery: { type: "string", enum: ["queue", "steer"], description: "Defaults to queue" },
          },
          required: ["sessionID", "text"],
          additionalProperties: false,
        },
        options: { namespace: "agents", codemode: true, pinned: true },
        execute: async (input, context) => {
          const { sessionID, text, delivery } = input as {
            sessionID: string
            text: string
            delivery?: "queue" | "steer"
          }
          if (sessionID === context.sessionID) return { content: "Refusing to message the current session." }
          await ctx.session.prompt({
            sessionID: sessionID as never,
            text: `[message from session ${context.sessionID}]\n\n${text}`,
            metadata: { from: context.sessionID },
            delivery: delivery ?? "queue",
          })
          return { content: `Sent to ${sessionID}.` }
        },
      })
    })
  },
})
