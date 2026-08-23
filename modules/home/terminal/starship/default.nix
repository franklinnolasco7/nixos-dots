{ config, lib, ... }:

let
  minimal = config.myProfile == "minimal";

  colors = config.lib.stylix.colors.withHashtag;

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
    // lib.optionalAttrs (!minimal) {
      cmd_duration = {
        min_time = 500;
        format = "[$duration](bold ${colors.base0A}) ";
      };

      character = {
        success_symbol = "[❯](bold ${colors.base06})";
        error_symbol = "[❯](bold ${colors.base0F})";
      };

      directory = {
        style = "bold ${colors.base06}";
      };

      git_branch = {
        style = "bold ${colors.base0D}";
      };

      git_status = {
        stashed = "[](bold ${colors.base0B}) ";
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
    }
    // lib.optionalAttrs minimal {
      character = {
        success_symbol = "[>]";
        error_symbol = "[!]";
      };

      aws.disabled = true;
      docker_context.disabled = true;
      git_commit.disabled = true;
    };
  };
}
