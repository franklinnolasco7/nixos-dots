{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell.Networking

  Item {
      id: root

      readonly property var dev: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
      readonly property bool radioOn: Networking.wifiEnabled && Networking.wifiHardwareEnabled
      readonly property var net: dev ? dev.networks.values.find(n => n.connected) : null
      // Codepoints verified against Google's Material Symbols codepoints table;
      // rendered filled via the variable font's FILL axis below.
      readonly property string iconGlyph: !radioOn ? "\ue648" /* wifi_off */
          : net && net.signalStrength >= 0.8 ? "\ue1ba" /* network_wifi */
          : net && net.signalStrength >= 0.6 ? "\uebe1" /* network_wifi_3_bar */
          : net && net.signalStrength >= 0.4 ? "\uebd6" /* network_wifi_2_bar */
          : net && net.signalStrength >= 0.2 ? "\uebe4" /* network_wifi_1_bar */
          : "\uf0b0" /* signal_wifi_0_bar */

      visible: !!dev
      height: parent.height
      implicitHeight: 26
      implicitWidth: iconText.width + ${toString (layout.modulePadding * 2)}

      Text {
          id: iconText
          anchors.centerIn: parent
          text: root.iconGlyph
          color: "${colors.base0A}"
          font.family: "Material Symbols Rounded"
          font.variableAxes: {
              "FILL": 1
          }
          font.pixelSize: 14
      }
  }
''
