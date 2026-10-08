export const NotificationPlugin = async ({ $ }) => {
  const runningSessions = new Set()

  return {
    event: async ({ event }) => {
      if (event.type === "session.status" && event.properties?.status === "running") {
        runningSessions.add(event.properties.sessionID)
      }

      if (event.type === "session.idle") {
        const id = event.properties?.sessionID
        if (id && runningSessions.has(id)) {
          runningSessions.delete(id)
          const title = event.properties?.title ?? "Session complete"
          // Single osascript call: shows notification AND plays sound
          const script = `display notification "Task complete" with title "OpenCode" subtitle ${JSON.stringify(title)} sound name "Glass"`
          await $`osascript -e ${script}`
        }
      }
    },
  }
}
