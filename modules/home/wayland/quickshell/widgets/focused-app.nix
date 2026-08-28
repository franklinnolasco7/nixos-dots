{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell.Hyprland

  Item {
      id: root

      property string appClass: ""

      property string refreshedFor: ""

      // Track whether a special workspace is open; when it closes, the
      // active toplevel may linger on the special window (empty workspace
      // with no window to re-focus), so we need this gate to clear the
      // label.
      property bool specialOpen: false

      implicitHeight: 26
      height: parent.height
      implicitWidth: visible ? nameLabel.implicitWidth + ${
        toString (layout.wideModulePadding * 2)
      } : 0
      visible: appClass !== ""

      Connections {
          target: Hyprland

          function onActiveToplevelChanged() {
              updateAppClass();
          }

          function onFocusedWorkspaceChanged() {
              updateAppClass();
          }

          function onRawEvent(event) {
              if (event.name !== "activespecial") return;
              const parts = event.parse(2);
              specialOpen = parts[0] !== "";
              updateAppClass();
          }
      }

      // Re-run when IPC data arrives on the active toplevel, so the class
      // name appears on the first open of a special workspace window.
      Connections {
          target: Hyprland.activeToplevel
          function onLastIpcObjectChanged() {
              updateAppClass();
          }
      }

      function updateAppClass() {
          const toplevel = Hyprland.activeToplevel;

          if (toplevel && toplevel.workspace) {
              if (toplevel.workspace.name.startsWith("special:") && root.specialOpen) {
                  root.appClass = String(toplevel.lastIpcObject.class ?? "");
              } else {
                  const workspace = Hyprland.focusedWorkspace;
                  if (workspace && toplevel.workspace.id === workspace.id) {
                      root.appClass = String(toplevel.lastIpcObject.class ?? "");
                  } else {
                      root.appClass = "";
                  }
              }
          } else {
              root.appClass = "";
          }

          if (toplevel && toplevel.address !== "" && root.refreshedFor !== toplevel.address) {
              root.refreshedFor = toplevel.address;
              Hyprland.refreshToplevels();
          }
      }

      Text {
          id: nameLabel
          anchors.centerIn: parent
          text: root.appClass.length > 60
              ? root.appClass.slice(0, 59) + "…" : root.appClass
          elide: Text.ElideRight
          color: "${colors.base0D}"
          font.family: "Inter"
          font.pixelSize: 12
      }
  }
''
