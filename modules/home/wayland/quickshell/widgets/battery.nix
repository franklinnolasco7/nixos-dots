{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell.Services.UPower

  Row {
      id: root

      readonly property var dev: UPower.displayDevice
      // UPower.percentage is a 0-1 ratio (energy / energyCapacity), not 0-100.
      readonly property int pct: Math.round(dev.percentage * 100)
      readonly property bool charging: dev.state == UPowerDeviceState.Charging
          || dev.state == UPowerDeviceState.PendingCharge
      // Codepoints verified against Google's Material Symbols codepoints table;
      // rendered filled via the variable font's FILL axis below.
      readonly property string iconGlyph: charging ? "\ue1a3" /* battery_charging_full */
          : pct < 15 ? "\ue19c" /* battery_alert */
          : pct < 30 ? "\uf09c" /* battery_1_bar */
          : pct < 45 ? "\uf09d" /* battery_2_bar */
          : pct < 60 ? "\uf09e" /* battery_3_bar */
          : pct < 75 ? "\uf09f" /* battery_4_bar */
          : pct < 90 ? "\uf0a0" /* battery_5_bar */
          : "\ue1a5" /* battery_full */
      // Matches the clock's accent; only critically low turns red.
      readonly property color fg: pct < 15 ? "${colors.base08}" : "${colors.base0A}"

      // displayDevice may be returned before statistics are queried.
      visible: dev.ready
      height: parent.height
      spacing: 3
      leftPadding: ${toString layout.modulePadding}
      rightPadding: ${toString layout.modulePadding}

      Text {
          anchors.verticalCenter: parent.verticalCenter
          text: root.iconGlyph
          color: root.fg
          font.family: "Material Symbols Rounded"
          font.variableAxes: {
              "FILL": 1
          }
          font.pixelSize: 14
      }

      Text {
          anchors.verticalCenter: parent.verticalCenter
          text: root.pct + "%"
          color: root.fg
          font.family: "Inter"
          font.pixelSize: 12
      }
  }
''
