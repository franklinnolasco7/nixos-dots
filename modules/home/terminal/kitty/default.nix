{ lib, ... }:

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
    };

    keybindings = {
      "ctrl+shift+enter" = "new_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+w" = "close_tab";
    };
  };
}
