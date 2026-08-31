{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell

  Item {
      id: root

      readonly property color fg: "${colors.base04}"

      implicitHeight: 26
      height: parent.height
      implicitWidth: iconText.width + ${toString (layout.modulePadding * 2)}

      Text {
          id: iconText
          anchors.centerIn: parent
          text: "\ue5c3" /* apps */
          color: root.fg
          font.family: "Material Symbols Rounded"
          font.variableAxes: {
              "FILL": 1
          }
          font.pixelSize: 14
      }

      MouseArea {
          id: ma
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
              // The bar window may not be attached yet if the shell is still
              // spinning up right after load; guard so we never dereference
              // a null window (which would take the whole bar with it).
              const win = root.QsWindow.window;
              if (!win)
                  return;
              const rect = win.itemRect(root);
              if (!rect)
                  return;
              panel.anchor.window = win;
              panel.anchor.rect.x = rect.x + rect.width / 2 - panel.width / 2;
              panel.anchor.rect.y = rect.y + rect.height + 4;
              panel.visible = !panel.visible;
          }
      }

      ControlPanel {
          id: panel
      }
  }
''
