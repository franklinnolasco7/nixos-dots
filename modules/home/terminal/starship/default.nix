{ config, lib, ... }:

let
  minimal = config.myProfile == "minimal";
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
        format = "[$duration](bold #a6a6a6) ";
      };

      character = {
        # Minimal: ASCII-only; the console TTY font has no nerd glyphs.
        success_symbol = if minimal then "[>](bold #c8c8c8)" else "[❯](bold #c8c8c8)";
        error_symbol = if minimal then "[!](bold #5a5a5a)" else "[❯](bold #5a5a5a)";
      };

      directory = {
        style = "bold #e0e0e0";
      };

      git_branch = {
        style = "bold #d0d0d0";
      };

      git_status = {
        stashed = if minimal then "" else "[](bold #a8a8a8) ";
        style = "bold #5a5a5a";
      };

      git_commit = {
        tag_symbol = " ";
        style = "#c0c0c0";
      };

      aws = {
        symbol = " ";
        format = "[$symbol($profile)(\\[$region\\])]($style) ";
        style = "#b0b0b0";
      };

      docker_context = {
        symbol = " ";
        format = "[$symbol$context]($style) ";
        style = "#d0d0d0";
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
