{ config, lib, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
''
  @define-color background     ${colors.base00};
  @define-color background-alt ${colors.base01};
  @define-color foreground     ${colors.base08};
  @define-color selected       ${colors.base0A};
  @define-color active         ${colors.base0D};
  @define-color urgent         ${colors.base0F};

  @define-color text-dim       ${colors.base04};
  @define-color surface        ${colors.base02};
  @define-color hover          alpha(@surface, 0.8);
  @define-color overlay        ${colors.base01};
  @define-color critical       ${colors.base0E};
  @define-color button-hover   ${colors.base03};

  * {
    all: unset;
    font-size: 11px;
    font-family: "Inter", sans-serif;
    font-weight: 500;
  }

  .notification {
    padding: 0;
    border-radius: 0;
    border: none;
    color: @foreground;
    background: transparent;
  }

  .notification-background {
    background: @background;
    border-radius: 0;
    margin: 8px;
    border: 2px solid @selected;
  }

  .notification-content {
    margin: 14px;
  }

  .notification-content .text-box {
    margin: 0 0 0 14px;
  }

  .notification-content .time {
    font-size: 10px;
    font-weight: 600;
    color: @text-dim;
    padding: 3px 0;
    letter-spacing: 0.3px;
  }

  .notification .summary {
    font-weight: 700;
    font-size: 14px;
    color: @foreground;
    margin-bottom: 6px;
    padding: 2px 0;
  }

  .notification .body {
    color: @text-dim;
    font-size: 12px;
    line-height: 1.5;
  }

  .notification.low .notification-background {
    border-color: @overlay;
    border-width: 1px;
  }

  .notification.normal .notification-background {
    border-color: @selected;
    border-width: 2px;
  }

  .notification.critical .notification-background {
    border-color: @critical;
    border-width: 2px;
    background: alpha(@critical, 0.18);
  }

  .notification.critical .summary {
    color: @critical;
  }

  .notification.critical .body {
    color: @critical;
  }



  .notification.low progress,
  .notification.normal progress,
  .notification.critical progress {
    background: @background-alt;
    border-radius: 0;
    margin-top: 8px;
  }

  .notification.low progress::-webkit-progress-value {
    background: @overlay;
    border-radius: 0;
  }

  .notification.normal progress::-webkit-progress-value {
    background: @selected;
    border-radius: 0;
  }

  .notification.critical progress::-webkit-progress-value {
    background: @critical;
    border-radius: 0;
  }

  .notification-background .close-button {
    margin: 10px;
    padding: 6px;
    border-radius: 0;
    background: transparent;
    color: @text-dim;
    transition: all 0.15s ease;
  }

  .notification-background .close-button:hover {
    background: @surface;
    color: @foreground;
    transform: scale(1.1);
  }

  .notification-row .inline-reply-entry {
    padding: 10px 14px;
    background: @background-alt;
    border-radius: 0;
    color: @foreground;
    border: 2px solid @surface;
    transition: border-color 0.15s ease;
  }

  .notification-row .inline-reply-entry:focus {
    border-color: @selected;
  }

  .notification-row .inline-reply-button {
    padding: 10px 16px;
    border-radius: 0;
    background: @surface;
    color: @foreground;
    font-weight: 600;
    transition: all 0.15s ease;
    border: 2px solid transparent;
  }

  .notification-row .inline-reply .inline-reply-button:hover {
    background: @selected;
    color: @background;
    border-color: @selected;
  }

  .notification > *:last-child > * {
    min-height: 3.5em;
  }

  .notification > *:last-child > * .notification-action {
    background: @surface;
    margin: 0 8px 10px 8px;
    border-radius: 0;
    padding: 10px 16px;
    color: @foreground;
    font-weight: 600;
    transition: all 0.15s ease;
    border: 2px solid transparent;
  }

  .notification > *:last-child > * .notification-action:hover {
    background: @overlay;
    border-color: @selected;
  }

  .notification > *:last-child > * .notification-action:active {
    background: @selected;
    color: @background;
  }

  .control-center {
    background: @background;
    border-radius: 0;
    margin: 8px;
    padding: 14px;
    border: 2px solid @selected;
  }

  .control-center .notification-background {
    background: @background-alt;
    margin: 8px 0;
    border-radius: 0;
    border: 1px solid @surface;
  }

  .control-center .notification-background .close-button,
  .notification-group-close-button {
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.15s ease;
  }

  .control-center .notification-background:hover .close-button {
    opacity: 1;
    pointer-events: auto;
  }

  .notification-group {
    margin: 0 8px;
  }

  .notification-group-headers {
    font-weight: 700;
    color: @foreground;
    padding: 10px 0;
  }

  .notification-group-headers > label {
    margin: 0 8px;
    font-size: 14px;
  }

  .notification-group-icon {
    color: @active;
    margin-right: 6px;
  }

  .notification-group-collapse-button,
  .notification-group-close-all-button {
    background: transparent;
    color: @foreground;
    margin: 4px;
    border-radius: 0;
    padding: 8px 12px;
    font-weight: 600;
    transition: all 0.15s ease;
    border: 2px solid transparent;
  }

  .notification-group-collapse-button:hover,
  .notification-group-close-all-button:hover {
    background: @surface;
    border-color: @selected;
  }

  .widget-dnd {
    padding: 10px 14px;
    border-radius: 0;
    margin: 6px 0;
    color: @foreground;
    background: @background-alt;
    border: 2px solid @surface;
  }

  .widget-dnd > label {
    font-size: 13px;
    font-weight: 600;
  }

  .widget-dnd switch {
    background: @surface;
    border-radius: 0;
    padding: 2px;
    min-width: 48px;
    min-height: 26px;
    transition: background-color 0.2s ease;
  }

  .widget-dnd switch:checked {
    background: @selected;
  }

  .widget-dnd switch slider {
    background: @foreground;
    border-radius: 0;
    min-width: 22px;
    min-height: 22px;
    margin: 0;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .widget-dnd switch:checked slider {
    background: @background;
  }

  .widget-dnd switch:hover {
    background: @overlay;
  }

  .widget-dnd switch:checked:hover {
    background: alpha(@selected, 0.85);
  }

  .widget-volume,
  .widget-backlight {
    padding: 10px 14px;
    margin: 6px 0;
    border-radius: 0;
    color: @foreground;
    font-weight: 600;
    background: @background-alt;
    border: 2px solid @surface;
  }

  .widget-volume label,
  .widget-backlight label {
    font-size: 15px;
    margin-right: 10px;
  }

  .widget-volume slider,
  .widget-backlight slider {
    background: transparent;
    border: none;
    min-width: 0;
    min-height: 0;
  }

  .widget-volume trough,
  .widget-backlight trough {
    background: @surface;
    border-radius: 0;
    min-height: 8px;
    padding: 0;
  }

  .widget-volume trough highlight,
  .widget-backlight trough highlight {
    background: @selected;
    border-radius: 0;
  }

  .widget-volume highlight,
  .widget-backlight highlight {
    background: @selected;
    border-radius: 0;
    margin: 0;
  }

  .widget-mpris {
    background: @background-alt;
    border-radius: 0;
    margin: 6px 0;
    padding: 0 12px;
    border: 2px solid @surface;
  }

  .mpris-overlay {
    background: @background-alt;
  }

  .widget-mpris-player {
    background: @background-alt;
    color: @foreground;
    margin: 0;
    padding: 12px 0 14px;
  }

  .widget-mpris-album-art {
    border-radius: 0;
    margin: 8px 6px;
    min-width: 90px;
    min-height: 90px;
  }

  .widget-mpris-title {
    font-weight: 700;
    font-size: 13px;
    color: @foreground;
    margin: 0 6px 5px 6px;
  }

  .widget-mpris-subtitle {
    font-size: 11px;
    font-weight: 500;
    color: @text-dim;
    margin: 0 6px;
  }

  .widget-mpris-player button {
    padding: 6px;
    margin: 0 4px;
    border-radius: 0;
    background: transparent;
    color: @foreground;
    transition: all 0.15s ease;
    border: 2px solid transparent;
  }

  .widget-mpris-player button:hover {
    background: @surface;
    border-color: @active;
    transform: scale(1.05);
  }

  .widget-mpris-player button:active {
    background: @active;
    color: @background;
  }

  .widget-mpris-player .mpris-overlay > box:last-child {
    border-radius: 0;
    padding: 6px 8px;
    background: alpha(@surface, 0.6);
  }

  .widget-buttons-grid {
    border-radius: 0;
    padding: 10px;
    background: @background-alt;
    margin: 6px 0;
    border: 2px solid @surface;
  }

  .widget-buttons-grid button {
    padding: 8px;
    margin: 4px;
    background: @surface;
    border-radius: 0;
    color: @foreground;
    font-weight: 600;
    min-width: 44px;
    min-height: 44px;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    border: 2px solid transparent;
  }

  .widget-buttons-grid button > label {
    font-size: 18px;
    color: @foreground;
  }

  .widget-buttons-grid button:hover {
    background: @button-hover;
    border-color: @selected;
    transform: scale(1.05);
  }

  .widget-buttons-grid button:active {
    background: @selected;
    color: @background;
    transform: translateY(0);
  }

  .widget-buttons-grid button:checked {
    background: @selected;
    border: none;
  }

  .widget-buttons-grid button:checked > label {
    color: @background;
    font-weight: 700;
  }

  .widget-buttons-grid button:checked:hover {
    background: alpha(@selected, 0.85);
  }

  .control-center-list-placeholder {
    color: @text-dim;
    font-size: 13px;
    padding: 24px;
    text-align: center;
  }

  .control-center scrollbar {
    background: transparent;
    border-radius: 0;
    margin: 4px;
  }

  .control-center scrollbar slider {
    background: @surface;
    border-radius: 0;
    min-width: 8px;
  }

  .control-center scrollbar slider:hover {
    background: @overlay;
  }

  .blank-window {
    background: transparent;
  }

  .notification-content .notification-icon {
    color: @active;
    background: @surface;
    border-radius: 10px;
    padding: 8px;
  }
''
