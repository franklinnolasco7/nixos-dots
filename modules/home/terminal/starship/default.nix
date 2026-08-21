{ config, lib, ... }:

let
  minimal = config.myProfile == "minimal";
  colors =
    (config.lib.stylix or { }).colors.withHashtag or {
      base06 = "#c2c2c2";
      base07 = "#e0e0e0";
      base08 = "#5c5c5c";
      base0A = "#858585";
      base0B = "#999999";
      base0C = "#adadad";
      base0D = "#bfbfbf";
      base0E = "#d0d0d0";
    };
  disabledLangs = [
    "bun"
    "c"
    "cmake"
    "cobol"
    "cpp"
    "crystal"
    "daml"
    "dart"
    "deno"
    "dotnet"
    "elixir"
    "elm"
    "erlang"
    "fennel"
    "fortran"
    "gleam"
    "golang"
    "gradle"
    "haskell"
    "haxe"
    "helm"
    "java"
    "julia"
    "kotlin"
    "lua"
    "maven"
    "meson"
    "mojo"
    "nim"
    "nodejs"
    "ocaml"
    "odin"
    "opa"
    "perl"
    "php"
    "pulumi"
    "purescript"
    "python"
    "quarto"
    "raku"
    "red"
    "rlang"
    "ruby"
    "rust"
    "scala"
    "solidity"
    "swift"
    "typst"
    "vagrant"
    "vlang"
    "xmake"
    "zig"
  ];
  disabledTools = [
    "buf"
    "conda"
    "direnv"
    "env_var"
    "gcloud"
    "guix_shell"
    "mise"
    "openstack"
    "azure"
    "pixi"
    "spack"
  ];
in
{
  programs.starship = {
    enable = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      add_newline = false;
      command_timeout = 300;
      scan_timeout = 100;

      line_break = {
        disabled = true;
      };

      cmd_duration = {
        min_time = 500;
        format = "[$duration](bold ${colors.base0A}) ";
      };

      character = {
        # Minimal: ASCII-only; the console TTY font has no nerd glyphs.
        success_symbol = if minimal then "[>](bold ${colors.base0B})" else "[❯](bold ${colors.base0B})";
        error_symbol = if minimal then "[!](bold ${colors.base07})" else "[❯](bold ${colors.base07})";
      };

      directory = {
        style = "bold ${colors.base06}";
      };

      git_branch = {
        style = "bold ${colors.base0D}";
      };

      git_status = {
        stashed = if minimal then "" else "[](bold ${colors.base0B}) ";
        style = "bold ${colors.base0B}";
      };

      git_commit = {
        tag_symbol = " ";
        style = "${colors.base0C}";
      };

      aws = {
        symbol = " ";
        format = "[$symbol($profile)(\\[$region\\])]($style) ";
        style = "${colors.base0E}";
      };

      docker_context = {
        symbol = " ";
        format = "[$symbol$context]($style) ";
        style = "${colors.base0C}";
      };

      container = {
        disabled = true;
      };

      terraform = {
        disabled = true;
      };

      package = {
        disabled = true;
      };
    }
    // lib.genAttrs (disabledLangs ++ disabledTools) (name: {
      disabled = true;
    })
    // lib.optionalAttrs minimal {
      # Nerd-glyph modules have nothing meaningful to show on a console TTY.
      aws.disabled = true;
      docker_context.disabled = true;
      git_commit.disabled = true;
    };
  };
}
