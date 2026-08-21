{ config, lib, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
''
  @define-color bg ${colors.base00};
  @define-color surface ${colors.base01};
  @define-color border ${colors.base02};
  @define-color fg ${colors.base08};
  @define-color fg_muted ${colors.base04};

  @define-color accent_blue ${colors.base0D};
  @define-color accent_red ${colors.base04};
  @define-color urgent ${colors.base0F};
  @define-color accent_amber ${colors.base0A};
  @define-color accent_green ${colors.base0D};
  @define-color hover ${colors.base0A};
  @define-color critical ${colors.base04};

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
    color: @hover;
    background-color: transparent;
    box-shadow: none;
  }

  #workspaces button.active {
    color: ${colors.base0A};
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
      color: ${colors.base08};
    }
  }

  #clock {
    background-color: transparent;
    color: ${colors.base0A};
    padding: 0 8px;
    margin: 0;
    font-weight: 600;
    font-size: 12px;
  }

  #window {
    color: ${colors.base04};
    padding: 0 8px;
    font-size: 12px;
    font-weight: 400;
  }

  window#waybar.empty #window {
    padding: 0;
    margin: 0;
    opacity: 0;
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
    color: ${colors.base08};
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
    color: ${colors.base0A};
    box-shadow: none;
  }

  #pulseaudio:not(.microphone).muted,
  #pulseaudio.microphone.source-muted {
    color: @accent_red;
  }

  #network.disconnected,
  #bluetooth.disabled {
    color: ${colors.base04};
  }

  #battery.charging,
  #battery.plugged {
    color: @accent_green;
  }

  #battery.warning {
    color: @accent_amber;
  }

  #battery.critical {
    color: @critical;
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
    color: ${colors.base0A};
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
