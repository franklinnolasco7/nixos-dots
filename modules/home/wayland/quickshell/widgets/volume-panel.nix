{ colors }:
''
  import QtQuick
  import Quickshell
  import Quickshell.Services.Pipewire

  PopupWindow {
      id: panel

      // Bind both defaults so their volume/mute props are valid to read and set.
      PwObjectTracker {
          objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(n => !!n)
      }

      readonly property var sink: Pipewire.defaultAudioSink
      readonly property var source: Pipewire.defaultAudioSource
      readonly property real sinkVolume: sink?.audio?.volume ?? 0
      readonly property bool sinkMuted: !!sink?.audio?.muted
      readonly property real sourceVolume: source?.audio?.volume ?? 0
      readonly property bool sourceMuted: !!source?.audio?.muted

      implicitWidth: 300
      implicitHeight: contentColumn.childrenRect.height + 20
      visible: false
      // Clicking outside the popup closes it.
      grabFocus: true
      color: "transparent"

      Rectangle {
          anchors.fill: parent
          radius: 8
          color: "${colors.base01}"

          Column {
              id: contentColumn
              anchors {
                  left: parent.left
                  right: parent.right
                  top: parent.top
                  margins: 10
              }
              spacing: 8

              // macOS-style header: badge + title.
              Item {
                  width: parent.width
                  height: 26

                  Rectangle {
                      id: volBadge
                      anchors {
                          left: parent.left
                          verticalCenter: parent.verticalCenter
                      }
                      width: 26
                      height: 26
                      radius: 7
                      color: "${colors.base0D}"

                      Text {
                          anchors.centerIn: parent
                          text: "\ue050" /* volume_up */
                          color: "${colors.base00}"
                          font.family: "Material Symbols Rounded"
                          font.variableAxes: {
                              "FILL": 1
                          }
                          font.pixelSize: 16
                      }
                  }

                  Text {
                      anchors {
                          left: volBadge.right
                          leftMargin: 10
                          verticalCenter: parent.verticalCenter
                      }
                      text: "Volume"
                      color: "${colors.base04}"
                      font.family: "Inter"
                      font.pixelSize: 12
                  }
              }

              // --- Output ---
              Item {
                  width: parent.width
                  height: 24

                  Text {
                      anchors {
                          left: parent.left
                          verticalCenter: parent.verticalCenter
                      }
                      text: "Output"
                      color: "${colors.base04}"
                      font.family: "Inter"
                      font.pixelSize: 10
                  }

                  Text {
                      anchors {
                          right: parent.right
                          verticalCenter: parent.verticalCenter
                      }
                      text: panel.sinkMuted ? "Unmute" : "Mute"
                      color: panel.sinkMuted ? "${colors.base04}" : "${colors.base0A}"
                      font.family: "Inter"
                      font.pixelSize: 11

                      MouseArea {
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          onClicked: if (panel.sink && panel.sink.audio)
                              panel.sink.audio.muted = !panel.sink.audio.muted
                      }
                  }
              }

              VolumeSlider {
                  width: parent.width
                  value: panel.sinkVolume
                  muted: panel.sinkMuted
                  accent: "${colors.base0D}"
                  audio: panel.sink?.audio
              }

              Text {
                  width: parent.width
                  visible: !!panel.sink
                  text: panel.sink?.description ? panel.sink.description : (panel.sink?.name ?? "")
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 10
                  elide: Text.ElideRight
              }

              // --- Input (Microphone) ---
              Item {
                  width: parent.width
                  height: 24

                  Text {
                      anchors {
                          left: parent.left
                          verticalCenter: parent.verticalCenter
                      }
                      text: "Microphone"
                      color: "${colors.base04}"
                      font.family: "Inter"
                      font.pixelSize: 10
                  }

                  Text {
                      anchors {
                          right: parent.right
                          verticalCenter: parent.verticalCenter
                      }
                      text: panel.sourceMuted ? "Unmute" : "Mute"
                      color: panel.sourceMuted ? "${colors.base04}" : "${colors.base0A}"
                      font.family: "Inter"
                      font.pixelSize: 11

                      MouseArea {
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          onClicked: if (panel.source && panel.source.audio)
                              panel.source.audio.muted = !panel.source.audio.muted
                      }
                  }
              }

              VolumeSlider {
                  width: parent.width
                  value: panel.sourceVolume
                  muted: panel.sourceMuted
                  accent: "${colors.base0C}"
                  audio: panel.source?.audio
              }

              Text {
                  width: parent.width
                  visible: !!panel.source
                  text: panel.source?.description ? panel.source.description : (panel.source?.name ?? "")
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 10
                  elide: Text.ElideRight
              }

              Text {
                  width: parent.width
                  visible: !panel.sink && !panel.source
                  text: "No audio devices found"
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 11
              }
          }
      }
  }
''
