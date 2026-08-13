{ ... }:

{
  programs.kitty = {
    enable = true;

    shellIntegration.mode = "enabled";

    settings = {
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

      foreground = "#a6a6a6";
      background = "#080808";
      background_opacity = "0.98";

      selection_foreground = "#c4c4c4";
      selection_background = "#1a1a1a";

      cursor = "#c4c4c4";
      cursor_text_color = "#080808";

      url_color = "#8a8a8a";
      active_border_color = "#1a1a1a";
      inactive_border_color = "#121212";

      color0 = "#000000";
      color8 = "#444444";
      color1 = "#303030";
      color9 = "#5a5a5a";
      color2 = "#909090";
      color10 = "#c8c8c8";
      color3 = "#6e6e6e";
      color11 = "#a8a8a8";
      color4 = "#787878";
      color12 = "#b4b4b4";
      color5 = "#808080";
      color13 = "#bcbcbc";
      color6 = "#989898";
      color14 = "#d4d4d4";
      color7 = "#b8b8b8";
      color15 = "#f0f0f0";

      window_border_width = 0;
      cursor_shape = "block";
      cursor_blink_interval = "0.8";
      shell_integration = "enabled";
      notify_on_cmd_finish = "unfocused 5.0";
    };

    keybindings = {
      "ctrl+shift+enter" = "new_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+w" = "close_tab";
    };
  };
}
