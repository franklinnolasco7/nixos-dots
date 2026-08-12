{ inputs, ... }:

{
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
  ];

  programs.mcp.enable = true;

  programs.opencode = {
    enable = true;

    enableMcpIntegration = true;

    settings = {
      permission = {
        external_directory = "ask";
      };
    };
  };

  # opencode-mcp (https://github.com/AlaeddineMessadi/opencode-mcp)
  #
  # Lets any MCP client delegate coding work to OpenCode sessions via its
  # headless server API (80 tools, 10 resources, 6 prompts, multi-project).
  #
  # NOTE: it is meant to give OpenCode's power to OTHER MCP clients (Claude,
  # Cursor, VS Code, ...). Wiring it up inside OpenCode itself is recursive
  # (OpenCode would talk to an OpenCode server), so it is left disabled here.
  #
  # If you ever want to expose an OpenCode server to another client, run it
  # standalone instead:
  #   npx -y opencode-mcp
  # or add it as a custom server for that client:
  #   mcp-servers.settings.servers.opencode = {
  #     command = "${pkgs.nodejs}/bin/npx";
  #     args = [ "-y" "opencode-mcp" ];
  #   };
  #
  # Useful env vars: OPENCODE_BASE_URL (default http://127.0.0.1:4096),
  # OPENCODE_SERVER_PASSWORD, OPENCODE_AUTO_SERVE, OPENCODE_DEFAULT_MODEL.

  mcp-servers.programs = {
    nixos.enable = true;
    context7.enable = true;
    filesystem = {
      enable = true;
      args = [ "/home/frank" ];
    };
    git.enable = true;
    fetch.enable = true;
    sequential-thinking.enable = true;
    serena.enable = true;
    playwright.enable = true;
  };
}
