{ colors }:
''
  import QtQuick
  import Quickshell

  // Shared drag-to-set volume bar, used by the volume panel and the control
  // center. `audio` is the PwNodeAudio of the node being controlled (may be
  // null if no device); every write is guarded before it hits pipewire.
  Item {
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
''
