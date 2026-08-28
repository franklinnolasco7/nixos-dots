{ colors }:
''
  import QtQuick
  import Quickshell
  import Quickshell.Bluetooth

  PopupWindow {
      id: panel

      readonly property var adapter: Bluetooth.defaultAdapter

      // macOS-style sections: bonded devices vs freshly discovered ones.
      readonly property var myDevices: adapter && adapter.enabled ? adapter.devices.values.filter(d => d.paired || d.connected).sort((a, b) => (b.connected - a.connected) || String(a.name).localeCompare(String(b.name))) : []
      readonly property var nearbyDevices: adapter && adapter.enabled ? adapter.devices.values.filter(d => !d.paired && !d.connected).sort((a, b) => String(a.name).localeCompare(String(b.name))) : []

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
              spacing: 6

              // macOS header: blue badge + title + controls.
              Item {
                  width: parent.width
                  height: 28

                  Rectangle {
                      id: btBadge
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
                          text: "\ue1a7" /* bluetooth */
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
                          left: btBadge.right
                          leftMargin: 10
                          verticalCenter: parent.verticalCenter
                      }
                      text: "Bluetooth"
                      color: "${colors.base04}"
                      font.family: "Inter"
                      font.pixelSize: 12
                  }

                  Text {
                      anchors {
                          verticalCenter: parent.verticalCenter
                          right: toggleTrack.left
                          rightMargin: 12
                      }
                      text: panel.adapter && panel.adapter.discovering ? "Stop scan" : "Scan"
                      color: "${colors.base0A}"
                      font.family: "Inter"
                      font.pixelSize: 11

                      MouseArea {
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          onClicked: if (panel.adapter)
                              panel.adapter.discovering = !panel.adapter.discovering
                      }
                  }

                  // Adapter power toggle.
                  Rectangle {
                      id: toggleTrack
                      anchors {
                          verticalCenter: parent.verticalCenter
                          right: parent.right
                      }
                      width: 34
                      height: 18
                      radius: height / 2
                      color: panel.adapter && panel.adapter.enabled ? "${colors.base0D}" : "${colors.base02}"

                      MouseArea {
                          anchors.fill: parent
                          onClicked: if (panel.adapter)
                              panel.adapter.enabled = !panel.adapter.enabled
                      }

                      Rectangle {
                          anchors.verticalCenter: parent.verticalCenter
                          x: panel.adapter && panel.adapter.enabled ? toggleTrack.width - width - 2 : 2

                          Behavior on x {
                              NumberAnimation {
                                  duration: 150
                              }
                          }

                          width: 14
                          height: 14
                          radius: height / 2
                          color: "${colors.base00}"
                      }
                  }
              }

              // --- My Devices ---
              Text {
                  text: "My Devices"
                  visible: panel.myDevices.length > 0
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 10
              }

              Repeater {
                  model: panel.myDevices

                  delegate: Rectangle {
                      id: deviceRow

                      required property BluetoothDevice modelData

                      // Remaining auto-retries for connect(): stacks routinely
                      // drop the first connect right after pairing while audio
                      // profiles are still registering.
                      property int connectRetries: 0

                      function tryConnect() {
                          const d = deviceRow.modelData;
                          if (!d || d.connected || d.state != BluetoothDeviceState.Disconnected || deviceRow.connectRetries <= 0)
                              return;
                          deviceRow.connectRetries--;
                          d.connect();
                      }

                      Timer {
                          id: retryTimer
                          interval: 1500
                          onTriggered: deviceRow.tryConnect()
                      }

                      width: parent.width
                      height: 34
                      radius: 6
                      color: rowMa.containsMouse ? "${colors.base02}" : "transparent"

                      // React to connection-state flips: give up retrying once
                      // connected, retry on silent failures (state falls back
                      // to Disconnected), and auto-connect after fresh pairs.
                      Connections {
                          function onStateChanged() {
                              const d = deviceRow.modelData;
                              if (d.state == BluetoothDeviceState.Connected) {
                                  deviceRow.connectRetries = 0;
                                  retryTimer.stop();
                              } else if (d.state == BluetoothDeviceState.Disconnected && deviceRow.connectRetries > 0) {
                                  retryTimer.restart();
                              }
                          }

                          function onPairingChanged() {
                              const d = deviceRow.modelData;
                              if (!d.pairing && d.paired && d.state == BluetoothDeviceState.Disconnected) {
                                  deviceRow.connectRetries = 3;
                                  deviceRow.tryConnect();
                              }
                          }

                          target: deviceRow.modelData
                      }

                      // Theme icon over a guaranteed glyph fallback: themes
                      // sometimes miss SNI-style device names entirely.
                      Item {
                          id: devIconWrap
                          anchors {
                              left: parent.left
                              leftMargin: 8
                              verticalCenter: parent.verticalCenter
                          }
                          width: 16
                          height: 16

                          Text {
                              anchors.centerIn: parent
                              visible: devIcon.status !== Image.Ready
                              text: "\ue1a7" /* bluetooth */
                              color: "${colors.base04}"
                              font.family: "Material Symbols Rounded"
                              font.variableAxes: {
                                  "FILL": 1
                              }
                              font.pixelSize: 14
                          }

                          Image {
                              id: devIcon
                              anchors.fill: parent
                              // check=true yields an empty string for missing
                              // icons instead of a failed load request.
                              source: deviceRow.modelData.icon !== ""
                                  ? Quickshell.iconPath(deviceRow.modelData.icon, true) : ""
                              sourceSize {
                                  width: 16
                                  height: 16
                              }
                              asynchronous: true
                          }
                      }

                      Column {
                          anchors {
                              left: devIconWrap.right
                              leftMargin: 8
                              verticalCenter: parent.verticalCenter
                          }
                          spacing: 1

                          Text {
                              text: deviceRow.modelData.name !== "" ? deviceRow.modelData.name : deviceRow.modelData.address
                              color: deviceRow.modelData.connected ? "${colors.base0D}" : "${colors.base04}"
                              font.family: "Inter"
                              font.pixelSize: 12
                          }

                          Text {
                              visible: deviceRow.modelData.connected || deviceRow.modelData.pairing || deviceRow.modelData.state == BluetoothDeviceState.Connecting || deviceRow.modelData.state == BluetoothDeviceState.Disconnecting
                              text: deviceRow.modelData.pairing ? "Pairing…"
                                  : deviceRow.modelData.state == BluetoothDeviceState.Connecting ? "Connecting…"
                                  : deviceRow.modelData.state == BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                                  : deviceRow.modelData.batteryAvailable ? Math.round(deviceRow.modelData.battery * 100) + "% battery"
                                  : "Connected"
                              color: "${colors.base04}"
                              font.family: "Inter"
                              font.pixelSize: 10
                          }
                      }

                      // Row-level hover + click handling. Declared after the
                      // visuals so it covers them, but before forgetWrap so the
                      // forget hitbox stays on top of it.
                      MouseArea {
                          id: rowMa
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: {
                              const d = deviceRow.modelData;
                              if (d.pairing) {
                                  d.cancelPair();
                              } else if (d.state == BluetoothDeviceState.Connecting || d.state == BluetoothDeviceState.Disconnecting) {
                                  // Transition in progress; acting now races bluez.
                                  return;
                              } else if (d.connected) {
                                  d.disconnect();
                              } else {
                                  // Scanning while connecting breaks setup on
                                  // several adapters; the user can rescan.
                                  if (panel.adapter)
                                      panel.adapter.discovering = false;
                                  d.trusted = true;
                                  deviceRow.connectRetries = 3;
                                  deviceRow.tryConnect();
                                  if (!d.paired)
                                      d.pair();
                              }
                          }
                      }

                      // Right-side actions in one anchored Row so the labels can
                      // never overlap. Sits above rowMa; forgetHit has hover
                      // disabled on purpose so pointing at it does not clear
                      // rowMa.containsMouse and hide itself.
                      Row {
                          anchors {
                              verticalCenter: parent.verticalCenter
                              right: parent.right
                              rightMargin: 8
                          }
                          spacing: 12

                          Item {
                              id: forgetWrap
                              visible: rowMa.containsMouse && deviceRow.modelData.paired
                              width: forgetLabel.width
                              height: parent.height

                              Text {
                                  id: forgetLabel
                                  anchors.centerIn: parent
                                  text: "forget"
                                  color: "${colors.base08}"
                                  font.family: "Inter"
                                  font.pixelSize: 10
                              }

                              MouseArea {
                                  anchors.fill: parent
                                  cursorShape: Qt.PointingHandCursor
                                  onClicked: deviceRow.modelData.forget()
                              }
                          }

                          Text {
                              anchors.verticalCenter: parent.verticalCenter
                              text: deviceRow.modelData.pairing ? "Cancel"
                                  : deviceRow.modelData.connected || deviceRow.modelData.state == BluetoothDeviceState.Connecting ? "Disconnect"
                                  : deviceRow.modelData.paired ? "Connect"
                                  : "Pair"
                              color: "${colors.base0A}"
                              font.family: "Inter"
                              font.pixelSize: 11
                          }
                      }
                  }
              }

              Text {
                  visible: panel.adapter && panel.adapter.enabled && panel.myDevices.length === 0
                  text: "No devices paired yet"
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 11
              }

              // --- Nearby Devices ---
              Text {
                  text: panel.adapter && panel.adapter.discovering ? "Nearby Devices — searching…" : "Nearby Devices"
                  visible: panel.nearbyDevices.length > 0
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 10
              }

              Repeater {
                  model: panel.nearbyDevices

                  delegate: Rectangle {
                      id: nearbyRow

                      required property BluetoothDevice modelData

                      width: parent.width
                      height: 30
                      radius: 6
                      color: nearbyMa.containsMouse ? "${colors.base02}" : "transparent"

                      Text {
                          anchors {
                              left: parent.left
                              leftMargin: 8
                              verticalCenter: parent.verticalCenter
                          }
                          text: nearbyRow.modelData.name !== "" ? nearbyRow.modelData.name : nearbyRow.modelData.address
                          color: "${colors.base04}"
                          font.family: "Inter"
                          font.pixelSize: 12
                          elide: Text.ElideRight
                          width: parent.width - 90
                      }

                      Text {
                          anchors {
                              verticalCenter: parent.verticalCenter
                              right: parent.right
                              rightMargin: 8
                          }
                          text: nearbyRow.modelData.pairing ? "Cancel" : "Pair"
                          color: "${colors.base0A}"
                          font.family: "Inter"
                          font.pixelSize: 11
                      }

                      MouseArea {
                          id: nearbyMa
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: {
                              const d = nearbyRow.modelData;
                              if (d.pairing)
                                  d.cancelPair();
                              else
                                  d.pair();
                          }
                      }
                  }
              }

              Text {
                  visible: panel.adapter && panel.adapter.enabled && panel.adapter.discovering && panel.nearbyDevices.length === 0
                  text: "Searching for nearby devices…"
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 11
              }

              Text {
                  visible: !panel.adapter || !panel.adapter.enabled
                  text: panel.adapter ? "Bluetooth is off" : "No adapter found"
                  color: "${colors.base04}"
                  font.family: "Inter"
                  font.pixelSize: 11
              }
          }
      }
  }
''
