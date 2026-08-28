{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell

  Item {
      id: root

      implicitHeight: 26
      height: parent.height
      implicitWidth: timeLabel.implicitWidth + ${toString (layout.wideModulePadding * 2)}

      SystemClock {
          id: clock
          precision: SystemClock.Seconds
      }

      Text {
          id: timeLabel
          anchors.centerIn: parent
          text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
          color: "${colors.base0D}"
          font.family: "Inter"
          font.pixelSize: 12
      }
  }
''
