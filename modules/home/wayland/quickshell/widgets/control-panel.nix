{
  colors,
  backlightDevice,
  hasBacklight,
}:
''
  import QtQuick
  import Quickshell
  import Quickshell.Services.Pipewire
  import Quickshell.Bluetooth
  import Quickshell.Networking
  import Quickshell.Services.Mpris
  import Quickshell.Io

  PopupWindow {
      id: panel

      readonly property var sink: Pipewire.defaultAudioSink
      readonly property real sinkVolume: sink?.audio?.volume ?? 0
      readonly property bool sinkMuted: !!sink?.audio?.muted

      readonly property var adapter: Bluetooth.defaultAdapter
      readonly property bool wifiOn: Networking.wifiEnabled && Networking.wifiHardwareEnabled
      readonly property var wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
      readonly property var wifiNet: wifiDev ? wifiDev.networks.values.find(n => n.connected) : null

      // Active MPRIS player, following the end-4/MprisController pattern: a
      // per-player watcher tracks the most recently "touched" player, and we
      // additionally prefer anything that is actively playing so pausing the
      // current source falls back to another one that's running.
      property var player: null
      property var trackedPlayer: null

      function pickActive(): void {
          const values = (Mpris.players && Mpris.players.values) ? Mpris.players.values : [];
          let playing = null;
          for (var i = 0; i < values.length; i++) {
              const p = values[i];
              if (p && (p.isPlaying || p.playbackState === MprisPlaybackState.Playing)) {
                  playing = p;
                  break;
              }
          }
          const sel = playing ?? panel.trackedPlayer ?? (values.length > 0 ? values[0] : null);
          if (sel !== panel.player)
              panel.player = sel;
      }

      // Discover players the moment they appear so the art starts loading
      // behind the scenes, rather than only once the panel is opened.
      Connections {
          target: Mpris.players
          function onObjectInsertedPost() {
              panel.pickActive();
          }
          function onObjectRemovedPost() {
              panel.pickActive();
          }
      }

      // Attach a watcher to every player (ObjectModel has no aggregate signal
      // for per-object changes) so we notice state/track changes on *any*
      // player, e.g. pressing play on Spotify while YouTube is already playing.
      Instantiator {
          id: playerWatchers
          model: Mpris.players.values
          delegate: Connections {
              required property MprisPlayer modelData
              target: modelData

              Component.onCompleted: {
                  if (panel.trackedPlayer == null || modelData.isPlaying)
                      panel.trackedPlayer = modelData;
                  panel.pickActive();
              }

              Component.onDestruction: {
                  panel.pickActive();
              }

              function onPlaybackStateChanged() {
                  panel.trackedPlayer = modelData;
                  panel.pickActive();
              }

              function onTrackChanged() {
                  panel.pickActive();
              }

              function onPostTrackChanged() {
                  panel.pickActive();
              }

              function onTrackArtUrlChanged() {
                  panel.pickActive();
              }
          }
      }

      Component.onCompleted: panel.pickActive()

      // --- Album art ---
      // Qt's Image loads any scheme it supports, so we feed the art URL
      // straight to it (the documented approach). Fall back to the raw
      // metadata map because some players only expose art late in there.
      readonly property string artUrl: panel.player
          ? (panel.player.trackArtUrl || (panel.player.metadata && panel.player.metadata["mpris:artUrl"]) || "")
          : ""

      property real brightnessPct: 0

      implicitWidth: 340
      implicitHeight: contentColumn.childrenRect.height + 20
      visible: false
      // Clicking outside the popup closes it.
      grabFocus: true
      color: "transparent"

      // Bind the default sink so its volume/mute are tracked and readable here.
      PwObjectTracker {
          objects: [Pipewire.defaultAudioSink].filter(n => !!n)
      }

      ${
        if hasBacklight then
          ''
            Process {
                id: getBrightness
                running: false
                command: ["brightnessctl", "-d", "${backlightDevice}", "-m"]
                stdout: StdioCollector {
                    id: brightnessCollector
                    onStreamFinished: {
                        // Machine output: device,class,current,percent,max
                        const parts = brightnessCollector.text.trim().split(",");
                        if (parts.length >= 5) {
                            const max = parseInt(parts[4]);
                            if (max > 0)
                                panel.brightnessPct = parseInt(parts[2]) / max;
                        }
                    }
                }
            }

            Process {
                id: setBrightness
                running: false
                command: []
            }

            onVisibleChanged: {
                if (visible)
                    getBrightness.running = true;
            }
          ''
        else
          ""
      }

      ${
        if hasBacklight then
          ''
            function applyBrightness(pct: real): void {
                // Keep the knob where the user left it. exec() stops any
                // still-running set and relaunches, so throttled drag commits
                // always apply the latest value instead of queueing.
                panel.brightnessPct = pct;
                setBrightness.exec(["brightnessctl", "-d", "${backlightDevice}", "set", Math.round(pct * 100) + "%"]);
            }
          ''
        else
          ""
      }

      // macOS-style toggle tile: rounded tile with an icon, name and status.
      component ToggleTile : Item {
          id: tile

          required property string glyph
          required property string name
          required property bool active
          required property string status
          required property var tapped

          readonly property color fg: tile.active ? "${colors.base00}" : "${colors.base04}"

          width: (parent.width - 8) / 2
          height: 58

          Rectangle {
              id: tileBg
              anchors.fill: parent
              radius: 8
              color: tile.active ? "${colors.base0D}" : "${colors.base02}"
          }

          Column {
              anchors {
                  left: parent.left
                  leftMargin: 10
                  verticalCenter: parent.verticalCenter
              }
              spacing: 3

              Text {
                  text: tile.glyph
                  color: tile.fg
                  font.family: "Material Symbols Rounded"
                  font.variableAxes: {
                      "FILL": 1
                  }
                  font.pixelSize: 16
              }

              Text {
                  text: tile.name
                  color: tile.fg
                  font.family: "Inter"
                  font.pixelSize: 11
                  font.bold: true
              }

              Text {
                  text: tile.status
                  color: tile.fg
                  font.family: "Inter"
                  font.pixelSize: 9
                  opacity: 0.75
                  elide: Text.ElideRight
                  width: tile.width - 20
              }
          }

          MouseArea {
              id: tileMa
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: tile.tapped()
          }
      }

      // Brightness slider mirrors VolumeSlider's geometry but writes the backlight.
      ${
        if hasBacklight then
          ''
            component BrightnessSlider : Item {
                id: bsRoot

                readonly property real value: panel.brightnessPct
                readonly property real barHeight: 6
                readonly property real knobR: 7

                property bool dragging: false
                property real dragValue: 0
                readonly property real shown: bsRoot.dragging ? bsRoot.dragValue : bsRoot.value

                implicitWidth: 0
                implicitHeight: 20

                // Live-apply while dragging: brightnessctl is a spawn per set,
                // so commits are throttled rather than fired per mouse event.
                // A final write on release flushes the exact value.
                Timer {
                    id: bsCommit
                    interval: 40
                    onTriggered: panel.applyBrightness(bsRoot.dragValue)
                }

                function setFromX(x: real): void {
                    bsRoot.dragValue = Math.max(0, Math.min(1, x / trackWrap.width));
                    if (!bsCommit.running)
                        bsCommit.restart();
                }

                Item {
                    id: trackWrap
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: bsRoot.knobR * 2

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: bsRoot.barHeight
                        radius: height / 2
                        color: "${colors.base03}"
                        clip: true

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width * bsRoot.shown
                            radius: parent.radius
                            color: "${colors.base0D}"
                        }
                    }

                    Rectangle {
                        id: knob
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(1, bsRoot.shown)) * (trackWrap.width - width)
                        width: bsRoot.knobR * 2
                        height: bsRoot.knobR * 2
                        radius: width / 2
                        color: "${colors.base0D}"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (event) => {
                            bsRoot.dragging = true;
                            bsRoot.setFromX(event.x);
                        }
                        onPositionChanged: (event) => {
                            if (pressed)
                                bsRoot.setFromX(event.x);
                        }
                        onReleased: {
                            bsRoot.dragging = false;
                            bsCommit.stop();
                            panel.applyBrightness(bsRoot.dragValue);
                        }
                    }
                }
            }
          ''
        else
          ""
      }

      Rectangle {
          id: panelBg
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

              // --- Connectivity toggles ---
              Row {
                  width: parent.width
                  spacing: 8

                  ToggleTile {
                      glyph: panel.wifiOn ? "\ue1ba" /* network_wifi */ : "\ue648" /* wifi_off */
                      name: "Wi-Fi"
                      active: panel.wifiOn
                      status: panel.wifiOn ? (panel.wifiNet ? panel.wifiNet.name : "On") : "Off"
                      tapped: () => Networking.wifiEnabled = !Networking.wifiEnabled
                  }

                  ToggleTile {
                      glyph: panel.adapter && panel.adapter.enabled ? "\ue1a8" /* bluetooth_connected */ : "\ue1a7" /* bluetooth */
                      name: "Bluetooth"
                      active: !!panel.adapter && panel.adapter.enabled
                      status: panel.adapter && panel.adapter.enabled ? "On" : "Off"
                      tapped: () => {
                          if (panel.adapter)
                              panel.adapter.enabled = !panel.adapter.enabled
                      }
                  }
              }

              ${
                if hasBacklight then
                  ''
                    // --- Display brightness ---
                    Item {
                        width: parent.width
                        height: 24

                        Text {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            text: "\ue1ac" /* brightness_high */
                            color: "${colors.base04}"
                            font.family: "Material Symbols Rounded"
                            font.variableAxes: {
                                "FILL": 1
                            }
                            font.pixelSize: 12
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 22
                                verticalCenter: parent.verticalCenter
                            }
                            text: "Display"
                            color: "${colors.base04}"
                            font.family: "Inter"
                            font.pixelSize: 10
                        }
                    }

                    BrightnessSlider {
                        width: parent.width
                    }
                  ''
                else
                  ""
              }

              // --- Sound ---
              Item {
                  width: parent.width
                  height: 24

                  Text {
                      anchors {
                          left: parent.left
                          verticalCenter: parent.verticalCenter
                      }
                      text: "\ue050" /* volume_up */
                      color: "${colors.base04}"
                      font.family: "Material Symbols Rounded"
                      font.variableAxes: {
                          "FILL": 1
                      }
                      font.pixelSize: 12
                  }

                  Text {
                      anchors {
                          left: parent.left
                          leftMargin: 22
                          verticalCenter: parent.verticalCenter
                      }
                      text: "Sound"
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
                      color: panel.sinkMuted ? "${colors.base04}" : "${colors.base0D}"
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

              // --- Now Playing ---
              Rectangle {
                  width: parent.width
                  height: 64
                  radius: 8
                  color: "${colors.base02}"
                  visible: !!panel.player

                  Row {
                      anchors {
                          left: parent.left
                          leftMargin: 12
                          verticalCenter: parent.verticalCenter
                      }
                      spacing: 12

                      Rectangle {
                          id: artWrap
                          width: 36
                          height: 36
                          radius: 6
                          // Clip the art to a rounded thumbnail; tracks without
                          // art fall back to a music glyph over a base tile.
                          clip: true

                          Rectangle {
                              anchors.fill: parent
                              color: "${colors.base03}"
                          }

                          Text {
                              anchors.centerIn: parent
                              visible: art.status !== Image.Ready
                              text: "\ue405" /* music_note */
                              color: "${colors.base04}"
                              font.family: "Material Symbols Rounded"
                              font.variableAxes: {
                                  "FILL": 1
                              }
                              font.pixelSize: 18
                          }

                          Image {
                              id: art
                              anchors.fill: parent
                              source: panel.artUrl
                              sourceSize {
                                  width: 36
                                  height: 36
                              }
                              fillMode: Image.PreserveAspectCrop
                              // Decode at display size and keep it cached so
                              // a previously-seen art URL repaints instantly.
                              cache: true
                              smooth: false
                              asynchronous: true
                          }
                      }

                      Column {
                          width: parent.parent.width - 152
                          anchors.verticalCenter: parent.verticalCenter
                          spacing: 3

                          Text {
                              width: parent.width
                              text: panel.player ? (panel.player.trackTitle || "Unknown Title") : ""
                              color: "${colors.base0D}"
                              font.family: "Inter"
                              font.pixelSize: 12
                              elide: Text.ElideRight
                          }

                          Text {
                              width: parent.width
                              text: panel.player && panel.player.trackArtist ? panel.player.trackArtist : (panel.player ? panel.player.identity : "")
                              color: "${colors.base04}"
                              font.family: "Inter"
                              font.pixelSize: 10
                              elide: Text.ElideRight
                          }
                      }
                  }

                  Row {
                      id: mediaControls
                      anchors {
                          verticalCenter: parent.verticalCenter
                          right: parent.right
                          rightMargin: 12
                      }
                      spacing: 14

                      Text {
                          text: "\ue045" /* skip_previous */
                          color: panel.player && panel.player.canGoPrevious ? "${colors.base0D}" : "${colors.base03}"
                          font.family: "Material Symbols Rounded"
                          font.variableAxes: {
                              "FILL": 1
                          }
                          font.pixelSize: 16

                          MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: if (panel.player && panel.player.canGoPrevious)
                                  panel.player.previous()
                          }
                      }

                      Text {
                          text: panel.player && panel.player.isPlaying ? "\ue034" /* pause */ : "\ue037" /* play_arrow */
                          color: panel.player && panel.player.canTogglePlaying ? "${colors.base0D}" : "${colors.base03}"
                          font.family: "Material Symbols Rounded"
                          font.variableAxes: {
                              "FILL": 1
                          }
                          font.pixelSize: 20

                          MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: if (panel.player && panel.player.canTogglePlaying)
                                  panel.player.togglePlaying()
                          }
                      }

                      Text {
                          text: "\ue044" /* skip_next */
                          color: panel.player && panel.player.canGoNext ? "${colors.base0D}" : "${colors.base03}"
                          font.family: "Material Symbols Rounded"
                          font.variableAxes: {
                              "FILL": 1
                          }
                          font.pixelSize: 16

                          MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: if (panel.player && panel.player.canGoNext)
                                  panel.player.next()
                          }
                      }
                  }
              }

              Text {
                  width: parent.width
                  visible: !panel.player
                  text: "Nothing playing"
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 11
              }
          }
      }
  }
''
