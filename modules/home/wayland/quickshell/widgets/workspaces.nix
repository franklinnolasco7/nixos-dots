{ colors }:
''
  import QtQuick
  import Quickshell.Hyprland

  Row {
      id: root

      height: parent.height
      spacing: 2
      readonly property int moduleMargin: 0

      // Track whether a special workspace is open on the focused monitor.
      // Hyprland's socket2 "activespecial" event is the only reactive signal;
      // monitors[].specialWorkspace and focusedWorkspace don't update for it.
      property bool specialOpen: false
      property string specialName: ""

      Connections {
          target: Hyprland
          function onRawEvent(event) {
              if (event.name !== "activespecial") return;
              const parts = event.parse(2);
              const mon = Hyprland.focusedMonitor;
              if (mon && parts[1] === mon.name) {
                  specialOpen = parts[0] !== "";
                  specialName = parts[0];
              }
          }
      }

      Component.onCompleted: {
          // lastIpcObject isn't fresh until the monitor info is refetched,
          // so pull it first or the initial special-workspace state is stale.
          Hyprland.refreshMonitors();
          const mon = Hyprland.focusedMonitor;
          if (mon) {
              const sw = mon.lastIpcObject.specialWorkspace;
              specialName = sw ? sw.name : "";
              specialOpen = specialName !== "";
          }
      }

      leftPadding: moduleMargin
      rightPadding: moduleMargin
      Repeater {
          // Hide the special workspace icon unless it is open; a closed
          // special workspace (name mismatch) drops out of the model.
          model: Hyprland.workspaces.values.filter(w =>
              !w.name.startsWith("special:") || w.name === root.specialName)

          delegate: Item {
              id: ws

              required property HyprlandWorkspace modelData

              readonly property int horizontalPadding: 11
              readonly property bool isSpecial: ws.modelData.name.startsWith("special:")
              implicitHeight: parent.height
              implicitWidth: label.implicitWidth + (horizontalPadding * 2)

              Text {
                  id: label
                  anchors.centerIn: parent
                  text: isSpecial ? "\uf4c8" : ws.modelData.name !== ""
                      ? ws.modelData.name : String(ws.modelData.id)
                  color: ws.modelData.urgent ? "${colors.base0F}"
                      : ma.containsMouse ? "${colors.base0A}"
                      : isSpecial ? (root.specialOpen ? "${colors.base0D}" : "${colors.base04}")
                      : root.specialOpen ? "${colors.base04}"
                      : ws.modelData.active ? "${colors.base0D}"
                      : "${colors.base04}"
                  font.family: isSpecial ? "Material Symbols Rounded" : "Inter"
                  font.pixelSize: isSpecial ? 14 : 12
                  font.weight: Font.Medium

                  SequentialAnimation on color {
                      running: ws.modelData.urgent
                      loops: Animation.Infinite
                      ColorAnimation {
                          to: "${colors.base08}"
                          duration: 500
                      }
                      ColorAnimation {
                          to: "${colors.base0F}"
                          duration: 500
                      }
                  }

                  Behavior on color {
                      ColorAnimation {
                          duration: 200
                      }
                  }
              }

              MouseArea {
                  id: ma
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: ws.modelData.activate()
              }
          }
      }
  }
''
