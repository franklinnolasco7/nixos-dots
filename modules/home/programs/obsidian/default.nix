{
  pkgs,
  ...
}:

let
  p = pkgs.obsidianPlugins;
in
{
  programs.obsidian = {
    enable = true;

    vaults.notes.target = "Documents/Obsidian";

    defaultSettings = {
      # mono-black is a dark-only theme; force dark mode explicitly.
      appearance = {
        theme = "obsidian";
      };

      communityPlugins = [
        p.calendar
        p.obsidian-excalidraw-plugin
        p.obsidian-git
      ];

      themes = [
        pkgs.obsidianThemes.mono-black-monochrome-charcoal
      ];
    };
  };
}
