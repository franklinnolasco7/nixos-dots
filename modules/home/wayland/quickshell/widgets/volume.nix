{ colors }:
let
  layout = import ../layout.nix;
in
''
  import QtQuick
  import Quickshell
  import Quickshell.Services.Pipewire

  Item {
      id: root

      // Bind the default sink so its volume/mute are tracked and readable here.
      PwObjectTracker {
          objects: [Pipewire.defaultAudioSink].filter(n => !!n)
      }

      readonly property var sink: Pipewire.defaultAudioSink
      readonly property real volume: sink?.audio?.volume ?? 0
      readonly property bool muted: !!sink?.audio?.muted
      // Codepoints verified against Google's Material Symbols codepoints table;
      // rendered filled via the variable font's FILL axis below.
      readonly property string iconGlyph: muted || root.volume == 0 ? "\ue04f" /* volume_off */
          : root.volume < 0.5 ? "\ue04d" /* volume_down */
          : "\ue050" /* volume_up */
      readonly property color fg: "${colors.base0D}"

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

      VolumePanel {
          id: panel
      }
  }
''
