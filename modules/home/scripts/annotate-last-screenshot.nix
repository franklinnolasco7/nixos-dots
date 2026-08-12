{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "annotate-last-screenshot" ''
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      latest=$(ls -t "$SCREENSHOT_DIR"/*.png 2>/dev/null | head -n 1)

      [[ -z $latest ]] && echo "No screenshots found" >&2 && exit 1

      satty -f "$latest" --copy-command 'wl-copy' --early-exit --output-filename "$latest" || {
        echo "Could not open satty" >&2
        exit 1
      }
    '')
  ];
}
