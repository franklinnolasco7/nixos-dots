{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages =
    # Core utilities; console-safe, always present (the minimal profile's tools).
    (with pkgs; [
      gh
    ])
    ++ lib.optionals (config.myProfile == "full") (
      with pkgs;
      [
        curl
        jq
        gawk
        tree
        rtk
        wireguard-tools
        rsync

        ripgrep
        fd
        eza
        bat
        fzf

        libnotify
        chromium
        xdg-utils
        glib
        mpv

        neovim
        vscodium

        lua

        pavucontrol
        pulseaudio

        localsend
        ani-cli
        github-copilot-cli
        antigravity-ide-fhs
        codeburn
      ]
    );
}
