{
  config,
  lib,
  pkgs,
  ...
}:

let
  minimal = config.myProfile == "minimal";
  raw = config.myPalette;
  colors = raw;
  hex = lib.mapAttrs (_: v: "#${v}") raw;

  # Cached, near-instant nix package count (see scripts/pkgs.nix).
  pkgsScript = import ./scripts/pkgs.nix { inherit pkgs; };

  hexToRgb =
    hex:
    let
      r = lib.trivial.fromHexString (builtins.substring 0 2 hex);
      g = lib.trivial.fromHexString (builtins.substring 2 2 hex);
      b = lib.trivial.fromHexString (builtins.substring 4 2 hex);
    in
    "${toString r};${toString g};${toString b}";

  block = hex: "{#38;2;${hexToRgb hex}}██";

  paletteRow1 =
    "  "
    + lib.concatMapStrings (key: block colors.${key}) [
      "base00"
      "base01"
      "base02"
      "base03"
      "base04"
      "base05"
      "base06"
      "base07"
    ]
    + "{#}";

  paletteRow2 =
    "  "
    + lib.concatMapStrings (key: block colors.${key}) [
      "base08"
      "base09"
      "base0A"
      "base0B"
      "base0C"
      "base0D"
      "base0E"
      "base0F"
    ]
    + "{#}";
in
{
  home.file.".local/libexec/fastfetch/pkgs" = {
    source = "${pkgsScript}/bin/pkgs";
    executable = true;
  };

  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";

      logo =
        if minimal then
          # ASCII logo; no kitty image protocol on a console TTY.
          {
            type = "small";
            padding = {
              top = 2;
              right = 2;
            };
          }
        else
          {
            type = "kitty";
            source = "${./logo.webp}";
            width = 40;
            height = 16;
            padding = {
              top = 2;
              right = 2;
            };
          };

      display = {
        separator = "  ";
        key = {
          width = 10;
        };
      }
      // lib.optionalAttrs (!minimal) {
        color = {
          keys = hex.base04;
          title = hex.base0D;
          output = hex.base05;
        };
      };

      modules = [
        {
          type = "custom";
          format = "";
        }
        {
          type = "title";
          format = "{user-name} @ {host-name}";
        }
        {
          type = "separator";
          string = "────────────────";
        }
        {
          type = "os";
          key = "distro";
        }
        {
          type = "kernel";
          key = "kernel";
        }
        # "host" module reports the DMI product name; shown here as the device.
        {
          type = "host";
          key = "device";
          format = "{name}";
        }
        {
          type = "uptime";
          key = "uptime";
        }
        # Built-in "packages" pays 5+ nix-store spawns every run (~66ms),
        # mostly to re-verify counts that only change on rebuild. This
        # command module caches the counts keyed by generation fingerprints,
        # so steady state is ~1ms with the same output. The script reports
        # the system and user store closures separately (see scripts/pkgs.nix).
        {
          type = "command";
          key = "pkgs";
          text = "${config.home.homeDirectory}/.local/libexec/fastfetch/pkgs";
          format = "{result}";
        }
        {
          type = "shell";
          key = "shell";
        }
        {
          type = "terminal";
          key = "term";
        }
      ]
      ++ lib.optionals (!minimal) [
        # No window manager on a console TTY.
        # Built-in "wm" detection takes ~100ms (it probes Hyprland's socket
        # repeatedly); asking hyprctl directly when a session is live costs
        # ~15ms but takes ~1ms otherwise. Runs parallel with other modules.
        {
          type = "command";
          key = "wm";
          text = ''
            if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
              hyprctl version 2>/dev/null | head -1 | awk '{print $1, $2, "(Wayland)"}'
            else
              printf '%s\n' "''${XDG_CURRENT_DESKTOP:-none}"
            fi
          '';
          format = "{result}";
        }
      ]
      ++ [
        {
          type = "cpu";
          key = "cpu";
          temp = false;
          showPeCoreCount = false;
        }
        {
          type = "gpu";
          key = "gpu";
          temp = false;
        }
        {
          type = "memory";
          key = "mem";
        }
        {
          type = "disk";
          key = "disk";
          folders = [
            "/"
            "/home"
          ];
          showExternal = false;
          showHidden = false;
          showSubvolumes = false;
          showReadOnly = false;
        }
      ]
      ++ lib.optionals (!minimal) [
        "break"
        {
          type = "custom";
          format = paletteRow1;
        }
        {
          type = "custom";
          format = paletteRow2;
        }
        {
          type = "custom";
          format = "\n";
        }
      ];
    };
  };
}
