{ colors }:
''
  import QtQuick
  import Quickshell.Hyprland

  Row {
      id: root

      height: parent.height
      spacing: 2

      // A special/scratchpad workspace is "active" when the focused monitor
      // has one open (its specialWorkspace.name is set). Hyprland's workspace
      // `active`/`focused` flags don't reflect this, so read the monitor's
      // lastIpcObject like the reference shells do; it's refreshed via the
      // socket event below because lastIpcObject only updates on a fetch.
      readonly property string specialName: Hyprland.focusedMonitor
          ? Hyprland.focusedMonitor.lastIpcObject.specialWorkspace?.name ?? "" : ""
      readonly property bool specialActive: root.specialName !== ""

      Connections {
          target: Hyprland
          function onRawEvent(event) {
              if (event.name === "activespecial")
                  Hyprland.refreshMonitors();
          }
      }

      Repeater {
          model: Hyprland.workspaces.values.filter(w =>
              !w.name.startsWith("special:")
              || w.name === root.specialName
              || w.toplevels.values.length > 0)

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
                  // The open special lights up; regular workspaces dim while a
                  // special is the current view, otherwise highlight on active.
                  color: ws.modelData.urgent ? "${colors.base0F}"
                      : ma.containsMouse ? "${colors.base0A}"
                      : isSpecial ? (ws.modelData.name === root.specialName ? "${colors.base0D}" : "${colors.base04}")
                      : root.specialActive ? "${colors.base04}"
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
