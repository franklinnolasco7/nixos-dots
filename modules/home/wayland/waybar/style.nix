let
  colors = import ../../styling/palette.nix;
in
''
  @define-color bg ${colors.base};
  @define-color surface ${colors.surfaceAlt};
  @define-color border ${colors.surface};
  @define-color fg ${colors.fg};
  @define-color fg_muted ${colors.textDim};

  @define-color accent_blue ${colors.selected};
  @define-color accent_red ${colors.accentRed};
  @define-color urgent ${colors.urgent};
  @define-color accent_amber ${colors.accentAmber};
  @define-color accent_green ${colors.active};

  * {
    font-family: "Inter", "JetBrainsMono Nerd Font", sans-serif;
    font-size: 12px;
    font-weight: 500;
    border: none;
    border-radius: 0;
    min-height: 0;
    margin: 0;
    padding: 0;
  }

  window#waybar {
    background-color: @bg;
    color: @fg;
    border-bottom: 1px solid #1a1a1a;
  }

  .modules-left,
  .modules-center,
  .modules-right {
    padding: 0 4px;
  }

  tooltip {
    background: none;
    border: none;
  }

  tooltip.background {
    background-color: @surface;
    border-radius: 6px;
    border: 1px solid @border;
  }

  tooltip label {
    font-family: "Inter", "JetBrainsMono Nerd Font", sans-serif;
    color: @fg;
    padding: 6px 10px;
  }

  tooltip label tt {
    font-family: "JetBrainsMono Nerd Font", monospace;
  }

  #workspaces {
    background-color: transparent;
    padding: 0;
    margin: 0 4px;
  }

  #workspaces button {
    padding: 0 6px;
    margin: 0 1px;
    border-radius: 0;
    color: @fg_muted;
    background-color: transparent;
    font-size: 12px;
    font-weight: 500;
    transition: color 0.2s ease;
  }

  #workspaces button:hover {
    color: #848484;
    background-color: transparent;
    box-shadow: none;
  }

  #workspaces button.active {
    color: #c4c4c4;
    font-weight: 700;
    background-color: transparent;
    box-shadow: none;
  }

  #workspaces button.urgent {
    color: @urgent;
    animation-name: urgent-blink;
    animation-duration: 1s;
    animation-timing-function: steps(12);
    animation-iteration-count: infinite;
    animation-direction: alternate;
  }

  @keyframes urgent-blink {
    from {
      color: @urgent;
    }
    to {
      color: #ffffff;
    }
  }

  #clock {
    background-color: transparent;
    color: #c4c4c4;
    padding: 0 8px;
    margin: 0;
    font-weight: 600;
    font-size: 12px;
  }

  #window {
    color: #848484;
    padding: 0 8px;
    font-size: 12px;
    font-weight: 400;
  }

  #cpu,
  #memory,
  #pulseaudio,
  #pulseaudio.microphone,
  #network,
  #bluetooth,
  #battery,
  #tray,
  #mpris,
  #custom-notification,
  #idle_inhibitor {
    background-color: transparent;
    color: #a6a6a6;
    padding: 0 6px;
    margin: 0 2px;
    font-size: 12px;
    font-weight: 500;
    box-shadow: none;
  }

  #idle_inhibitor.activated {
    color: @accent_blue;
  }

  #cpu:hover,
  #memory:hover,
  #pulseaudio:hover,
  #pulseaudio.microphone:hover,
  #network:hover,
  #bluetooth:hover,
  #battery:hover,
  #tray:hover,
  #custom-notification:hover,
  #idle_inhibitor:hover {
    background-color: transparent;
    color: #c4c4c4;
    box-shadow: none;
  }

  #pulseaudio:not(.microphone).muted,
  #pulseaudio.microphone.source-muted {
    color: @accent_red;
  }

  #network.disconnected,
  #bluetooth.disabled {
    color: #4a4a4a;
  }

  #battery.charging,
  #battery.plugged {
    color: @accent_green;
  }

  #battery.warning {
    color: @accent_amber;
  }

  #battery.critical {
    color: @accent_red;
  }

  #custom-notification.notification {
    color: @accent_blue;
  }

  #group-tray-expander {
    background-color: transparent;
    padding: 0;
    margin: 0;
  }

  #custom-expand-icon {
    font-family: "JetBrainsMono Nerd Font", sans-serif;
    background-color: transparent;
    color: @fg;
    padding: 0 6px;
    margin: 0 2px;
    font-size: 14px;
  }

  #custom-expand-icon:hover {
    color: #c4c4c4;
    background-color: transparent;
  }

  #group-tray-expander:not(.expanded) #tray {
    opacity: 0;
  }

  #group-tray-expander.expanded #tray {
    opacity: 1;
    background-color: transparent;
    padding: 0 4px;
  }

  #tray {
    background-color: transparent;
  }

  #tray > * {
    padding: 0 3px;
    margin: 0 2px;
  }
''
