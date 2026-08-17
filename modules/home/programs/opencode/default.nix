{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  # Caveman (https://github.com/juliusbrussee/caveman) is not packaged in
  # nixpkgs, so pin the source directly.
  cavemanSrc = pkgs.fetchFromGitHub {
    owner = "juliusbrussee";
    repo = "caveman";
    rev = "099327780ef69ad88c4cfc15c54314579ac367a4";
    hash = "sha256-1noGOiyAJig8ujSL9kuz1IgZqb/wiDmWl9XWwNn+kw4=";
  };

  # rtk (https://github.com/rtk-ai/rtk) ships its skills and opencode plugin in
  # its source tree, but pkgs.rtk follows nixpkgs-unstable, so a bump that
  # renames or moves them would fail every eval with an obscure path error.
  rtkSrc = pkgs.fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "700bdde3343299ea06bbca18dc6670a80c88b289";
    hash = "sha256-qOWWHov0m3A8V48r/UGN2Hxz+/XraPRYhNPnZ+B+ZBY=";
  };

  # rtk ships its skills under .claude/skills in its source tree. Most have
  # proper `name:` frontmatter and are symlinked straight from the source.
  rtkSkill = name: "${rtkSrc}/.claude/skills/${name}";

  # Five rtk skills (performance, pr-review, repo-recap, security-guardian,
  # ship) lack the `name:` frontmatter field that opencode requires, so they
  # are inlined with the field prepended.
  rtkNamedSkill = name: ''
    name: ${name}
    ${builtins.readFile "${rtkSrc}/.claude/skills/${name}/SKILL.md"}
  '';

  cavemanSkill = name: "${cavemanSrc}/skills/${name}";

  # Notify plugin: notify when opencode asks a question (the question tool) or
  # for permission (unless the active window is kitty, since opencode runs
  # inside it and the prompt is already visible) and when a task finishes
  # (session.idle), regardless of the focused window. Inlined, not checked in;
  # config lives in Nix modules.
  notifyPlugin = pkgs.writeText "opencode-notify.ts" ''
    export const NotifyPlugin = async ({ $ }) => {
      const kittyFocused = async () => {
        try {
          const active = JSON.parse(await $`hyprctl activewindow -j`.text())
          return active?.class === "kitty"
        } catch {
          return true
        }
      }

      return {
        "tool.execute.before": async (input, output) => {
          if (input.tool !== "question" || await kittyFocused()) return

          const summary = output.args.questions?.[0]?.question
            ?? "opencode is waiting for an answer"
          await $`notify-send -a opencode -i terminal "opencode" "Question: ''${summary}"`
        },
        event: async ({ event }) => {
          if (event.type === "session.idle") {
            await $`notify-send -a opencode -i terminal "opencode" "opencode finished the task"`
            return
          }

          if (event.type !== "permission.asked" || await kittyFocused()) return

          await $`notify-send -a opencode -i terminal "opencode" "opencode is waiting for permission: ''${event.permission}"`
        },
      }
    }
  '';

  # Sensitive paths opencode must never read. Guard plugin: blocks the read,
  # grep, glob, list, and mcp filesystem tools on these paths via
  # tool.execute.before. Inlined, not checked in; config lives in Nix modules.
  sensitivePaths = [
    "${config.home.homeDirectory}/.config/opencode/context7-key"
    "${config.home.homeDirectory}/.config/opencode/github-token"
    "${config.home.homeDirectory}/.config/github/projects-token"
    "/run/secrets"
  ];

  sensitiveFilesPlugin = pkgs.writeText "opencode-sensitive-files.ts" ''
    export const SensitiveFilesPlugin = async () => {
      const fs = await import("node:fs")
      const path = await import("node:path")
      const os = await import("node:os")
      const home = os.homedir()

      const sensitive = ${builtins.toJSON sensitivePaths}
        .map((p) => { try { return fs.realpathSync(p) } catch { return p } })
        .map((p) => (p.endsWith("/") ? p : p + "/"))

      const isSensitive = (p) => {
        if (typeof p !== "string" || !p) return false
        const abs = path.resolve(p.startsWith("~") ? home + p.slice(1) : p)
        let real
        try { real = fs.realpathSync(abs) } catch { real = abs }
        const norm = real.endsWith("/") ? real : real + "/"
        return sensitive.some((s) => norm.startsWith(s))
      }

      return {
        "tool.execute.before": async (input, output) => {
          const tool = input.tool
          const args = output.args ?? {}
          const paths = []
          if (tool === "read" && args.filePath) paths.push(args.filePath)
          if ((tool === "grep" || tool === "glob" || tool === "list") && args.path) paths.push(args.path)
          if (tool.startsWith("mcp__filesystem__")) {
            if (args.path) paths.push(args.path)
            if (Array.isArray(args.paths)) paths.push(...args.paths)
          }
          const hit = paths.find(isSensitive)
          if (hit) throw new Error("Blocked: refusing to read sensitive path: " + hit)
        },
      }
    }
  '';

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

  # GitHub MCP server needs a PAT, which is provisioned by sops only on hosts
  # that import modules/nixos/tools/sops.nix (aspire7). Hosts set this flag
  # from their host-specific home.nix; the VM leaves it off and skips the
  # server instead of emitting one with an empty token.
  options.programs.opencode.enableGithubMcpServer = lib.mkEnableOption "the GitHub MCP server";

  config = {
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
        plugin = [
          "${rtkSrc}/hooks/opencode/rtk.ts"
          notifyPlugin
          sensitiveFilesPlugin
        ];
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
        args = [ config.home.homeDirectory ];
      };
      git.enable = true;
      fetch.enable = true;
      sequential-thinking.enable = true;
      serena.enable = true;
      playwright.enable = true;

      # Official github-mcp-server over stdio. The PAT is read at launch from the
      # sops-provisioned token file (passwordCommand), so the secret never lands
      # in the nix store or the generated opencode.json.
      github = lib.mkIf config.programs.opencode.enableGithubMcpServer {
        enable = true;
        passwordCommand = {
          GITHUB_PERSONAL_ACCESS_TOKEN = [
            "${pkgs.coreutils}/bin/cat"
            "${config.home.homeDirectory}/.config/opencode/github-token"
          ];
        };
      };
    };
  };
}
