{ pkgs, inputs, ... }:

let
  # Caveman (https://github.com/juliusbrussee/caveman) is not packaged in
  # nixpkgs, so pin the source directly.
  cavemanSrc = pkgs.fetchFromGitHub {
    owner = "juliusbrussee";
    repo = "caveman";
    rev = "099327780ef69ad88c4cfc15c54314579ac367a4";
    hash = "sha256-1noGOiyAJig8ujSL9kuz1IgZqb/wiDmWl9XWwNn+kw4=";
  };

  # rtk ships its skills under .claude/skills in its source tree. Most have
  # proper `name:` frontmatter and are symlinked straight from the source.
  rtkSkill = name: "${pkgs.rtk.src}/.claude/skills/${name}";

  # Five rtk skills (performance, pr-review, repo-recap, security-guardian,
  # ship) lack the `name:` frontmatter field that opencode requires, so they
  # are inlined with the field prepended.
  rtkNamedSkill = name: ''
    name: ${name}
    ${builtins.readFile "${pkgs.rtk.src}/.claude/skills/${name}/SKILL.md"}
  '';

  cavemanSkill = name: "${cavemanSrc}/skills/${name}";

  rtkSkills = {
    code-simplifier = rtkSkill "code-simplifier";
    design-patterns = rtkSkill "design-patterns";
    issue-triage = rtkSkill "issue-triage";
    performance = rtkNamedSkill "performance";
    pr-review = rtkNamedSkill "pr-review";
    pr-triage = rtkSkill "pr-triage";
    repo-recap = rtkNamedSkill "repo-recap";
    rtk-tdd = rtkSkill "rtk-tdd";
    rtk-triage = rtkSkill "rtk-triage";
    security-guardian = rtkNamedSkill "security-guardian";
    ship = rtkNamedSkill "ship";
    tdd-rust = rtkSkill "tdd-rust";
  };

  cavemanSkills = {
    caveman = cavemanSkill "caveman";
    cavecrew = cavemanSkill "cavecrew";
    caveman-commit = cavemanSkill "caveman-commit";
    caveman-compress = cavemanSkill "caveman-compress";
    caveman-discover = cavemanSkill "caveman-discover";
    caveman-evidence-review = cavemanSkill "caveman-evidence-review";
    caveman-explore = cavemanSkill "caveman-explore";
    caveman-help = cavemanSkill "caveman-help";
    caveman-learn = cavemanSkill "caveman-learn";
    caveman-manage = cavemanSkill "caveman-manage";
    caveman-optimize = cavemanSkill "caveman-optimize";
    caveman-review = cavemanSkill "caveman-review";
    caveman-setup = cavemanSkill "caveman-setup";
    caveman-stats = cavemanSkill "caveman-stats";
    investigate-first = cavemanSkill "investigate-first";
    lean-build = cavemanSkill "lean-build";
    migration = cavemanSkill "migration";
    safe-refactor = cavemanSkill "safe-refactor";
    surgical-patch = cavemanSkill "surgical-patch";
    verify-and-stop = cavemanSkill "verify-and-stop";
  };
in
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

      # rtk's opencode plugin (hooks/opencode/rtk.ts) rewrites bash commands
      # through `rtk` to cut bash output tokens. Requires `rtk` in PATH,
      # which is provided by pkgs.rtk (see modules/home/packages.nix).
      plugin = [ "${pkgs.rtk.src}/hooks/opencode/rtk.ts" ];
    };

    skills = rtkSkills // cavemanSkills;
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
