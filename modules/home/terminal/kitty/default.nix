{ config, lib, ... }:

let
  raw = config.myPalette;
  colors = lib.mapAttrs (_: v: "#${v}") raw;

  t = fg: bg: "${fg},${bg}";

  newtColors = lib.concatStringsSep " " [
    "root=${t colors.base00 colors.base00}"
    "border=${t colors.base0A colors.base03}"
    "window=${t colors.base03 colors.base03}"
    "shadow=${t colors.base0B colors.base0B}"
    "title=${t colors.base08 colors.base03}"
    "roottext=${t colors.base0A colors.base01}"
    "button=${t colors.base03 colors.base0B}"
    "actbutton=${t colors.base02 colors.base0B}"
    "compactbutton=${t colors.base08 colors.base03}"
    "actcompactbutton=${t colors.base04 colors.base0F}"
    "checkbox=${t colors.base04 colors.base01}"
    "actcheckbox=${t colors.base04 colors.base03}"
    "entry=${t colors.base0B colors.base01}"
    "disentry=${t colors.base03 colors.base01}"
    "label=${t colors.base05 colors.base03}"
    "listbox=${t colors.base0B colors.base03}"
    "actlistbox=${t colors.base0A colors.base03}"
    "sellistbox=${t colors.base0F colors.base01}"
    "actsellistbox=${t colors.base02 colors.base0B}"
    "textbox=${t colors.base0B colors.base03}"
    "acttextbox=${t colors.base0D colors.base03}"
    "emptyscale=${t colors.base0C colors.base0C}"
    "fullscale=${t colors.base04 colors.base04}"
    "helpline=${t colors.base01 colors.base0E}"
  ];
in
{
  # exo (used by Thunar's "Open Terminal Here" via exo-open --launch
  # TerminalEmulator) resolves the terminal from this file, not from MIME
  # associations.
  xdg.configFile."xfce4/helpers.rc".text = ''
    [Default]
    TerminalEmulator=kitty
  '';

  programs.kitty = {
    enable = true;

    shellIntegration.mode = "enabled";

    settings = {
      env = "NEWT_COLORS=" + newtColors;

      font_family = "JetBrainsMono Nerd Font";
      italic_font = "JetBrainsMono Nerd Font Italic";
      bold_font = "JetBrainsMono Nerd Font Bold";
      bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";
      font_size = 12;

      adjust_column_width = 1;
      disable_ligatures = "never";

      window_padding_width = 10;
      enable_audio_bell = false;
      remember_window_size = false;
      placement_strategy = "center";
      hide_window_decorations = "titlebar-only";
      adjust_line_height = 4;

      sync_to_monitor = false;

      scrollback_lines = 5000;
      scrollback_pager_history_size = 64;

      background_opacity = lib.mkForce "0.98";

      window_border_width = 0;
      cursor_shape = "block";
      cursor_blink_interval = "0.8";
      shell_integration = "enabled";
      notify_on_cmd_finish = "unfocused 5.0";

      background = "${colors.base00}";
      foreground = "${colors.base08}";
      cursor = "${colors.base08}";
      cursor_text_color = "${colors.base00}";
      selection_background = "${colors.base02}";
      selection_foreground = "${colors.base08}";
      url_color = "${colors.base0A}";

      color0 = "${colors.base00}";
      color1 = "${colors.base08}";
      color2 = "${colors.base08}";
      color3 = "${colors.base0A}";
      color4 = "${colors.base0D}";
      color5 = "${colors.base08}";
      color6 = "${colors.base0A}";
      color7 = "${colors.base0F}";

      color8 = "${colors.base04}";
      color9 = "${colors.base08}";
      color10 = "${colors.base08}";
      color11 = "${colors.base0A}";
      color12 = "${colors.base0D}";
      color13 = "${colors.base08}";
      color14 = "${colors.base0A}";
      color15 = "${colors.base0F}";
    };

    keybindings = {
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+w" = "close_tab";
    };
  };
}
