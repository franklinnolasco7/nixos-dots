{ config, ... }:

let
  mk = config.lib.formats.rasi.mkLiteral;
  colors = import ../../styling/palette.nix;
in
{
  programs.rofi.theme = {
    "*" = {
      # palette
      background = mk colors.base;
      "background-alt" = mk colors.surfaceAlt;
      foreground = mk colors.fg;
      selected = mk colors.selected;
      active = mk colors.active;
      urgent = mk colors.urgent;
      surface = mk colors.surface;
      overlay = mk colors.overlay;
      "text-dim" = mk colors.textDim;

      # global properties
      "border-colour" = mk "var(selected)";
      "handle-colour" = mk "var(surface)";
      "background-colour" = mk "var(background)";
      "foreground-colour" = mk "var(foreground)";
      "alternate-background" = mk "var(background)";
      "normal-background" = mk "var(background)";
      "normal-foreground" = mk "var(foreground)";
      "urgent-background" = mk "var(urgent)";
      "urgent-foreground" = mk "var(background)";
      "active-background" = mk "var(active)";
      "active-foreground" = mk "var(background)";
      "selected-normal-background" = mk "var(surface)";
      "selected-normal-foreground" = mk "var(foreground)";
      "selected-urgent-background" = mk "var(urgent)";
      "selected-urgent-foreground" = mk "var(background)";
      "selected-active-background" = mk "var(active)";
      "selected-active-foreground" = mk "var(background)";
      "alternate-normal-background" = mk "var(background)";
      "alternate-normal-foreground" = mk "var(foreground)";
      "alternate-urgent-background" = mk "var(background)";
      "alternate-urgent-foreground" = mk "var(urgent)";
      "alternate-active-background" = mk "var(background)";
      "alternate-active-foreground" = mk "var(active)";
    };

    window = {
      transparency = "false";
      location = mk "center";
      anchor = mk "center";
      fullscreen = false;
      width = mk "750px";
      "x-offset" = mk "0px";
      "y-offset" = mk "0px";
      enabled = true;
      margin = mk "0px";
      padding = mk "0px";
      border = mk "2px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@border-colour";
      cursor = "default";
      "background-color" = mk "@background-colour";
    };

    mainbox = {
      enabled = true;
      spacing = mk "16px";
      margin = mk "0px";
      padding = mk "24px";
      border = mk "0px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@border-colour";
      "background-color" = mk "transparent";
      children = [
        "inputbar"
        "listview"
        "mode-switcher"
      ];
    };

    inputbar = {
      enabled = true;
      spacing = mk "12px";
      margin = mk "0px";
      padding = mk "10px 14px";
      border = mk "2px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "var(surface)";
      "background-color" = mk "@alternate-background";
      "text-color" = mk "@foreground-colour";
      children = [
        "prompt"
        "entry"
      ];
    };

    prompt = {
      enabled = true;
      padding = mk "0px 8px 0px 0px";
      "background-color" = mk "transparent";
      "text-color" = mk "var(text-dim)";
      font = "inherit bold";
    };

    entry = {
      enabled = true;
      padding = mk "0px";
      "background-color" = mk "transparent";
      "text-color" = mk "@foreground-colour";
      cursor = mk "text";
      placeholder = "Type to search...";
      "placeholder-color" = mk "var(text-dim)";
      opacity = 1;
    };

    listview = {
      enabled = true;
      columns = 1;
      lines = 6;
      cycle = true;
      dynamic = true;
      scrollbar = true;
      layout = mk "vertical";
      reverse = false;
      "fixed-height" = true;
      "fixed-columns" = true;
      spacing = mk "8px";
      margin = mk "0px";
      padding = mk "0px";
      border = mk "0px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@border-colour";
      "background-color" = mk "transparent";
      "text-color" = mk "@foreground-colour";
      cursor = "default";
    };

    scrollbar = {
      width = mk "8px";
      "handle-width" = mk "8px";
      "handle-color" = mk "@handle-colour";
      "border-radius" = mk "0px";
      "background-color" = mk "transparent";
    };

    element = {
      enabled = true;
      spacing = mk "12px";
      margin = mk "0px";
      padding = mk "14px 16px";
      border = mk "2px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "transparent";
      "background-color" = mk "transparent";
      "text-color" = mk "@foreground-colour";
      cursor = mk "pointer";
      transition = "background-color 150ms ease, border-color 150ms ease";
    };

    "element normal.normal" = {
      "background-color" = mk "var(normal-background)";
      "text-color" = mk "var(normal-foreground)";
    };

    "element normal.urgent" = {
      "background-color" = mk "var(urgent-background)";
      "text-color" = mk "var(urgent-foreground)";
    };

    "element normal.active" = {
      "background-color" = mk "var(active-background)";
      "text-color" = mk "var(active-foreground)";
    };

    "element selected.normal" = {
      "background-color" = mk "var(selected-normal-background)";
      "text-color" = mk "var(selected-normal-foreground)";
      border = mk "2px solid";
      "border-color" = mk "@border-colour";
    };

    "element selected.urgent" = {
      "background-color" = mk "var(selected-urgent-background)";
      "text-color" = mk "var(selected-urgent-foreground)";
    };

    "element selected.active" = {
      "background-color" = mk "var(selected-active-background)";
      "text-color" = mk "var(selected-active-foreground)";
    };

    "element alternate.normal" = {
      "background-color" = mk "var(alternate-normal-background)";
      "text-color" = mk "var(alternate-normal-foreground)";
    };

    "element alternate.urgent" = {
      "background-color" = mk "var(alternate-urgent-background)";
      "text-color" = mk "var(alternate-urgent-foreground)";
    };

    "element alternate.active" = {
      "background-color" = mk "var(alternate-active-background)";
      "text-color" = mk "var(alternate-active-foreground)";
    };

    "element-icon" = {
      "background-color" = mk "transparent";
      "text-color" = mk "inherit";
      size = mk "28px";
      cursor = mk "inherit";
    };

    "element-text" = {
      "background-color" = mk "transparent";
      "text-color" = mk "inherit";
      highlight = mk "inherit";
      cursor = mk "inherit";
      "vertical-align" = mk "0.5";
      "horizontal-align" = mk "0.0";
    };

    "mode-switcher" = {
      enabled = true;
      expand = false;
      spacing = mk "8px";
      margin = mk "0px";
      padding = mk "0px";
      border = mk "0px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@border-colour";
      "background-color" = mk "transparent";
      "text-color" = mk "@foreground-colour";
    };

    button = {
      padding = mk "10px 16px";
      border = mk "2px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "transparent";
      "background-color" = mk "var(surface)";
      "text-color" = mk "@foreground-colour";
      cursor = mk "pointer";
      transition = "background-color 150ms ease, border-color 150ms ease, transform 100ms ease";
    };

    "button selected" = {
      "background-color" = mk "@selected";
      "text-color" = mk "@background-colour";
      border = mk "2px solid";
      "border-color" = mk "@selected";
    };

    message = {
      enabled = true;
      margin = mk "0px";
      padding = mk "0px";
      border = mk "0px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@border-colour";
      "background-color" = mk "transparent";
      "text-color" = mk "@foreground-colour";
    };

    textbox = {
      padding = mk "10px 14px";
      border = mk "1px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "var(surface)";
      "background-color" = mk "@alternate-background";
      "text-color" = mk "var(text-dim)";
      "vertical-align" = mk "0.5";
      "horizontal-align" = mk "0.0";
      highlight = mk "none";
      "placeholder-color" = mk "var(text-dim)";
      blink = true;
      markup = true;
    };

    "error-message" = {
      padding = mk "14px";
      border = mk "2px solid";
      "border-radius" = mk "0px";
      "border-color" = mk "@urgent";
      "background-color" = mk "@background-colour";
      "text-color" = mk "@urgent";
    };
  };

  xdg.configFile."rofi/theme-wallpaper.rasi".text = ''
    * {
        font: "Inter 12";

        background:     ${colors.base};
        background-alt: ${colors.surfaceAlt};
        surface:        ${colors.surface};
        foreground:     ${colors.fg};
        selected:       ${colors.selected};
        border:         ${colors.selected};
        placeholder:    ${colors.textDim};
    }

    window {
        width: 78%;
        height: 48%;
        location: center;

        border: 2px;
        border-color: @border;
        border-radius: 0px;
        background-color: @background;
    }

    mainbox {
        orientation: vertical;
        spacing: 16px;
        padding: 24px;
        background-color: transparent;
    }

    inputbar {
        children: [ prompt, entry ];
        spacing: 12px;
        padding: 12px;

        border: 2px;
        border-color: @surface;
        border-radius: 0px;
        background-color: @background-alt;
    }

    prompt {
        text-color: @placeholder;
        background-color: transparent;
    }

    entry {
        placeholder: "Type to search...";
        placeholder-color: @placeholder;
        text-color: @foreground;
        background-color: transparent;
    }

    listview {
        columns: 3;
        lines: 2;
        cycle: false;
        dynamic: true;
        layout: vertical;
        spacing: 18px;
        scrollbar: true;
        background-color: transparent;
    }

    scrollbar {
        width: 8px;
        handle-width: 8px;
        handle-color: @surface;
        border-radius: 0px;
        background-color: transparent;
    }

    element {
        orientation: vertical;
        padding: 16px;
        spacing: 12px;

        border: 2px;
        border-color: transparent;
        border-radius: 0px;
        background-color: transparent;
    }

    /* Must match thumbnail width in wallpaper.sh so tiles fill the grid */
    element-icon {
        size: 320px;
        border-radius: 0px;
        background-color: transparent;
    }

    element-text {
        horizontal-align: 0.5;
        vertical-align: 0.5;
        text-color: @foreground;
        background-color: transparent;
    }

    element selected {
        background-color: @background-alt;
        border: 2px;
        border-color: @border;
        border-radius: 0px;
    }
  '';
}
