export const PermissionNotify = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "permission.asked") return

      let active
      try {
        active = JSON.parse(await $`hyprctl activewindow -j`.text())
      } catch {
        return
      }

      if (active?.class === "kitty") return

      await $`notify-send -a opencode -i terminal "opencode" "opencode is waiting for permission: ${event.permission}"`
    },
  }
}
