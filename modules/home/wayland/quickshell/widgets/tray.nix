{ colors }:
''
  import QtQuick
  import Quickshell
  import Quickshell.Services.SystemTray

  Row {
      id: root

      readonly property int iconSize: 14

      visible: SystemTray.items.values.length > 0
      height: parent.height
      spacing: 2

      Repeater {
          model: SystemTray.items

          delegate: Rectangle {
              id: cell

              required property SystemTrayItem modelData

              // Passive items (e.g. spotify) are shown to match waybar's
              // show-passive-items = true; hiding them loses tray apps.
              radius: height / 2
              implicitWidth: icon.width + 4
              implicitHeight: 20
              anchors.verticalCenter: parent.verticalCenter
              color: ma.containsMouse ? "${colors.base01}" : "transparent"

              Behavior on color {
                  ColorAnimation {
                      duration: 150
                  }
              }

              Image {
                  id: icon
                  anchors.centerIn: parent
                  source: cell.modelData.icon
                  sourceSize {
                      width: root.iconSize
                      height: root.iconSize
                  }
                  asynchronous: true
              }

              MouseArea {
                  id: ma
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                  onClicked: mouse => {
                      // The bar window may not be attached yet if the shell is
                      // still spinning up right after load; guard so we never
                      // dereference a null window (which would take the bar with it).
                      if (mouse.button === Qt.RightButton || (mouse.button === Qt.LeftButton && cell.modelData.onlyMenu)) {
                          const win = cell.QsWindow.window;
                          if (!win)
                              return;
                          const rect = win.itemRect(cell);
                          if (!rect)
                              return;
                          cell.modelData.display(win, rect.x + rect.width / 2, rect.y + rect.height);
                      } else if (mouse.button === Qt.MiddleButton) {
                          cell.modelData.secondaryActivate();
                      } else {
                          cell.modelData.activate();
                      }
                  }

                  onWheel: wheel => cell.modelData.scroll(wheel.angleDelta.y, false)
              }
          }
      }
  }
''
