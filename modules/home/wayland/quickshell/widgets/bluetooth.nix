{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell
  import Quickshell.Bluetooth

  Item {
      id: root

      readonly property var adapter: Bluetooth.defaultAdapter
      readonly property int connectedCount: Bluetooth.devices.values.filter(d => d.connected).length
      // Codepoints verified against Google's Material Symbols codepoints table;
      // rendered filled via the variable font's FILL axis below.
      readonly property string iconGlyph: !adapter || !adapter.enabled ? "\ue1a9" /* bluetooth_disabled */
          : connectedCount > 0 ? "\ue1a8" /* bluetooth_connected */
          : "\ue1a7" /* bluetooth */
      readonly property color fg: !adapter || !adapter.enabled ? "${colors.base03}"
          : connectedCount > 0 ? "${colors.base0D}"
          : "${colors.base04}"

      // Hidden entirely on hosts without an adapter.
      visible: !!adapter
      implicitHeight: 26
      height: parent.height
      implicitWidth: iconText.width + ${toString (layout.modulePadding * 2)}

      Text {
          id: iconText
          anchors.centerIn: parent
          text: root.iconGlyph
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
              const win = root.QsWindow.window;
              const rect = win.itemRect(root);
              panel.anchor.window = win;
              panel.anchor.rect.x = rect.x + rect.width / 2 - panel.width / 2;
              panel.anchor.rect.y = rect.y + rect.height + 4;
              panel.visible = !panel.visible;
          }
      }

      BluetoothPanel {
          id: panel
      }
  }
''
