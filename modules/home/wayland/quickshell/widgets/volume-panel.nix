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

      // Simple drag/click-to-set volume bar. `audio` is the PwNodeAudio of the
      // node being controlled (may be null if no device); guarded before writes.
      component VolumeSlider : Item {
          id: sliderRoot

          required property real value
          required property bool muted
          required property color accent
          required property var audio

          implicitWidth: 0
          implicitHeight: 20

          readonly property real barHeight: 6
          readonly property real knobR: 7

          // Local drag value keeps the knob glued to the pointer. Pipewire
          // writes are throttled: firing one per mouse event floods the daemon
          // so the real volume lags behind during a fast drag. A final write on
          // release flushes the exact value.
          property bool dragging: false
          property real dragValue: 0
          readonly property real shown: sliderRoot.dragging ? sliderRoot.dragValue : sliderRoot.value

          Timer {
              id: commitTimer
              interval: 25
              onTriggered: {
                  if (sliderRoot.audio)
                      sliderRoot.audio.volume = sliderRoot.dragValue;
              }
          }

          function setFromX(x: real): void {
              if (!sliderRoot.audio)
                  return;
              const v = Math.max(0, Math.min(1, x / trackWrap.width));
              sliderRoot.dragValue = v;
              // Unmute once; writing it every move can race pipewire's restore.
              if (sliderRoot.audio.muted)
                  sliderRoot.audio.muted = false;
              if (!commitTimer.running)
                  commitTimer.restart();
          }

          Item {
              id: trackWrap
              anchors {
                  left: parent.left
                  right: parent.right
                  verticalCenter: parent.verticalCenter
              }
              height: sliderRoot.knobR * 2

              Rectangle {
                  anchors {
                      left: parent.left
                      right: parent.right
                      verticalCenter: parent.verticalCenter
                  }
                  height: sliderRoot.barHeight
                  radius: height / 2
                  color: "${colors.base03}"
                  clip: true

                  Rectangle {
                      anchors {
                          left: parent.left
                          top: parent.top
                          bottom: parent.bottom
                      }
                      width: parent.width * (sliderRoot.muted ? 0 : sliderRoot.shown)
                      radius: parent.radius
                      color: sliderRoot.accent
                  }
              }

              Rectangle {
                  id: knob
                  anchors.verticalCenter: parent.verticalCenter
                  x: Math.max(0, Math.min(1, sliderRoot.muted ? 0 : sliderRoot.shown)) * (trackWrap.width - width)
                  width: sliderRoot.knobR * 2
                  height: sliderRoot.knobR * 2
                  radius: width / 2
                  color: sliderRoot.muted ? "${colors.base04}" : sliderRoot.accent
              }

              MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onPressed: (event) => {
                      sliderRoot.dragging = true;
                      sliderRoot.setFromX(event.x);
                  }
                  onPositionChanged: (event) => {
                      if (pressed)
                          sliderRoot.setFromX(event.x);
                  }
                  onReleased: {
                      sliderRoot.dragging = false;
                      commitTimer.stop();
                      if (sliderRoot.audio)
                          sliderRoot.audio.volume = sliderRoot.dragValue;
                  }
              }
          }
      }

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
