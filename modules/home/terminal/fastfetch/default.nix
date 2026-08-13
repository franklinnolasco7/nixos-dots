{
  config,
  lib,
  pkgs,
  ...
}:

let
  minimal = config.myProfile == "minimal";
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";

      logo =
        if minimal then
          # ASCII logo — no kitty image protocol on a console TTY.
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
            source = "${./logo.jpg}";
            width = 32;
            height = 16;
            preserveAspectRatio = true;
            padding = {
              top = 2;
              right = 2;
            };
          };

      display = {
        separator = "  ";
        color = {
          keys = "white";
          title = "white";
          output = "white";
        };
        key = {
          width = 10;
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
        {
          type = "uptime";
          key = "uptime";
        }
        {
          type = "packages";
          key = "pkgs";
          combined = true;
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
        {
          type = "wm";
          key = "wm";
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
        "break"
        {
          type = "custom";
          format = "  {#38;2;26;26;26}██{#38;2;51;51;51}██{#38;2;77;77;77}██{#38;2;102;102;102}██{#38;2;128;128;128}██{#38;2;153;153;153}██{#38;2;179;179;179}██{#38;2;204;204;204}██{#}";
        }
        {
          type = "custom";
          format = "  {#38;2;217;217;217}██{#38;2;230;230;230}██{#38;2;242;242;242}██{#38;2;255;255;255}██{#38;2;242;242;242}██{#38;2;230;230;230}██{#38;2;217;217;217}██{#38;2;204;204;204}██{#}";
        }
        {
          type = "custom";
          format = "\n";
        }
      ];
    };
  };
}
