{ colors, hasBattery }:
''
  // Platform tray menus require QApplication mode.
  //@ pragma UseQApplication
  import QtQuick
  import Quickshell
  import Quickshell.Wayland

  ShellRoot {
      Variants {
          model: Quickshell.screens

          PanelWindow {
              id: bar

              required property var modelData

              // Mirrors waybar's layout CSS: 4px group edge padding, 4px
              // inter-module gaps (its margin: 0 2px pairs); each widget owns
              // its own inner padding (6px, clock/window 8px).
              readonly property int screenMargin: 4
              readonly property int itemGap: 4

              screen: modelData
              anchors {
                  top: true
                  left: true
                  right: true
              }
              implicitHeight: 26
              color: "transparent"

              WlrLayershell.namespace: "qs-bar"

              Rectangle {
                  anchors.fill: parent
                  color: "${colors.base00}"
              }

              component Side: Row {
                  height: parent.height
                  spacing: bar.itemGap
              }

              Side {
                  anchors {
                      left: parent.left
                      leftMargin: bar.screenMargin
                      verticalCenter: parent.verticalCenter
                  }

                  OsLogo {}
                  Workspaces {}
                  FocusedApp {}
              }

              Side {
                  anchors {
                      right: parent.right
                      rightMargin: bar.screenMargin
                      verticalCenter: parent.verticalCenter
                  }

                  Bluetooth {}
                  Volume {}
                  Wifi {}
                  ${if hasBattery then "Battery {}" else ""}
                  Tray {}
                  Clock {}
              }
          }
      }
  }
''
