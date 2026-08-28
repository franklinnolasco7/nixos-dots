{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell.Io

  Item {
      id: root

      property string distroId: ""

      implicitHeight: 26
      height: parent.height
      implicitWidth: glyph.implicitWidth + ${toString (layout.modulePadding * 2)}

      function glyphFor(id) {
          const glyphs = {
              nixos: "\uF313",
              arch: "\uF303",
              ubuntu: "\uF31b",
              fedora: "\uF30a",
              debian: "\uF306",
              manjaro: "\uF312"
          };
          // Generic tux for distros outside the map.
          return glyphs[id] ?? "\uF31a";
      }

      FileView {
          id: osRelease
          path: "/etc/os-release"
          blockLoading: true
      }

      Component.onCompleted: {
          const match = osRelease.text().match(/^ID="?([^"\n]+)"?$/m);
          if (match)
              root.distroId = match[1];
      }

      Text {
          id: glyph
          anchors.centerIn: parent
          text: root.glyphFor(root.distroId)
          color: ma.containsMouse ? "${colors.base0A}" : "${colors.base0D}"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 13
      }

      MouseArea {
          id: ma
          anchors.fill: parent
          hoverEnabled: true
      }
  }
''
