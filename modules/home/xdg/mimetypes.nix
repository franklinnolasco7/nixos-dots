{ ... }:

{
  xdg.mimeApps = {
    enable = true;

    # NOTE: some associated apps (vesktop, figma-linux, wine, onlyoffice,
    # freetube, gitkraken, inkscape, xournalpp, amberol, vlc, DaVinciResolve,
    # gimp, libreoffice, xed, gthumb, claude-code-url-handler, ...) are NOT
    # declared in this flake; they're installed imperatively by choice. The
    # associations are inert until such an app exists; keep them so the binding
    # is correct once the app is present.

    defaultApplications = {
      "image/png" = "org.gnome.gThumb.desktop";
      "x-scheme-handler/discord" = "vesktop.desktop";
      "application/vnd.microsoft.portable-executable" = "wine.desktop";
      "text/plain" = "codium.desktop";
      "x-scheme-handler/figma" = "figma-linux.desktop";
      "audio/mpeg" = "io.bassi.Amberol.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
        "onlyoffice-desktopeditors.desktop";
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "text/html" = "codium.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "text/css" = "codium.desktop";
      "text/x-lua" = "codium.desktop";
      "x-scheme-handler/freetube" = "FreeTube.desktop";
      "text/x-devicetree-source" = "codium.desktop";
      "text/x-csrc" = "codium.desktop";
      "text/x-scss" = "org.x.editor.desktop";
      "x-scheme-handler/gitkraken" = "GitKraken.desktop";
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "application/schema+json" = "codium.desktop";
      "application/x-shellscript" = "codium.desktop";
      "application/json" = "codium.desktop";
      "text/x-c++src" = "codium.desktop";
      "audio/x-flac+ogg" = "mpv.desktop";
      "audio/x-vorbis+ogg" = "io.bassi.Amberol.desktop";
      "inode/directory" = "thunar.desktop";
      "application/x-terminal-emulator" = "kitty.desktop";
      "x-scheme-handler/terminal" = "kitty.desktop";
      "text/x-c" = "codium.desktop";
      "application/x-zerosize" = "codium.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "application/xml" = "codium.desktop";
      "video/mp4" = "mpv.desktop";
      "application/vnd.sqlite3" = "codium.desktop";
      "application/x-php" = "codium.desktop";
      "application/pgp-keys" = "codium.desktop";
      "video/x-matroska" = "mpv.desktop";
      "application/x-trash" = "codium.desktop";
      "x-scheme-handler/antigravity" = "antigravity.desktop";
    };

    associations.added = {
      "image/png" = [
        "satty.desktop"
        "org.gnome.gThumb.desktop"
      ];
      "application/vnd.microsoft.portable-executable" = [
        "faugus-launcher.desktop"
        "org.gnome.FileRoller.desktop"
        "wine.desktop"
      ];
      "video/x-matroska" = [
        "vlc.desktop"
        "mpv.desktop"
      ];
      "audio/mpeg" = [ "io.bassi.Amberol.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
        "onlyoffice-desktopeditors.desktop"
      ];
      "application/pdf" = [
        "org.pwmt.zathura-pdf-mupdf.desktop"
        "com.github.xournalpp.xournalpp.desktop"
        "onlyoffice-desktopeditors.desktop"
        "org.pwmt.zathura.desktop"
      ];
      "image/jpeg" = [
        "imv.desktop"
        "org.gnome.gThumb.desktop"
      ];
      "text/css" = [
        "org.x.editor.desktop"
        "codium.desktop"
      ];
      "text/x-lua" = [ "codium.desktop" ];
      "text/x-devicetree-source" = [
        "codium.desktop"
        "org.x.editor.desktop"
      ];
      "application/x-shellscript" = [
        "org.x.editor.desktop"
        "codium.desktop"
      ];
      "text/x-csrc" = [
        "org.x.editor.desktop"
        "codium.desktop"
      ];
      "text/x-scss" = [ "org.x.editor.desktop" ];
      "image/svg+xml" = [
        "org.gimp.GIMP.desktop"
        "libreoffice-draw.desktop"
        "org.inkscape.Inkscape.desktop"
      ];
      "application/json" = [ "codium.desktop" ];
      "text/x-makefile" = [ "codium.desktop" ];
      "audio/x-flac+ogg" = [
        "mpv.desktop"
        "io.bassi.Amberol.desktop"
        "vlc.desktop"
      ];
      "audio/x-vorbis+ogg" = [ "io.bassi.Amberol.desktop" ];
      "application/x-zerosize" = [ "codium.desktop" ];
      "application/x-msdownload" = [ "faugus-shortcut.desktop" ];
      "application/xml" = [ "codium.desktop" ];
      "video/mp4" = [
        "mpv.desktop"
        "vlc.desktop"
        "DaVinciResolve.desktop"
      ];
      "application/vnd.sqlite3" = [ "codium.desktop" ];
      "text/html" = [ "codium.desktop" ];
      "application/x-php" = [ "codium.desktop" ];
      "inode/directory" = [ "codium.desktop" ];
      "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "application/pgp-keys" = [ "codium.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "video/quicktime" = [ "vlc.desktop" ];
      "application/x-trash" = [ "codium.desktop" ];
    };
  };
}
