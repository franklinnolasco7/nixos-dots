{ ... }:

{
  xdg.mimeApps.enable = true;

  # NOTE: some associated apps (vesktop, figma-linux, wine, onlyoffice,
  # freetube, gitkraken, inkscape, xournalpp, amberol, vlc, DaVinciResolve,
  # gimp, libreoffice, xed, gthumb, claude-code-url-handler, ...) are NOT
  # declared in this flake; they're installed imperatively by choice. The
  # associations are inert until such an app exists; keep them so the binding
  # is correct once the app is present.

  xdg.mimeApps.defaultApplications = {
    "image/png" = "org.gnome.gThumb.desktop";
    "x-scheme-handler/discord" = "vesktop.desktop";
    "application/vnd.microsoft.portable-executable" = "wine.desktop";
    "text/plain" = "code-oss.desktop";
    "x-scheme-handler/figma" = "figma-linux.desktop";
    "audio/mpeg" = "io.bassi.Amberol.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      "onlyoffice-desktopeditors.desktop";
    "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    "image/jpeg" = "org.gnome.gThumb.desktop";
    "text/html" = "code-oss.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
    "text/css" = "code-oss.desktop";
    "text/x-lua" = "code-oss.desktop";
    "x-scheme-handler/freetube" = "FreeTube.desktop";
    "text/x-devicetree-source" = "code-oss.desktop";
    "text/x-csrc" = "code-oss.desktop";
    "text/x-scss" = "org.x.editor.desktop";
    "x-scheme-handler/gitkraken" = "GitKraken.desktop";
    "image/svg+xml" = "org.inkscape.Inkscape.desktop";
    "application/schema+json" = "code-oss.desktop";
    "application/x-shellscript" = "code-oss.desktop";
    "application/json" = "code-oss.desktop";
    "text/x-c++src" = "code-oss.desktop";
    "audio/x-flac+ogg" = "mpv.desktop";
    "audio/x-vorbis+ogg" = "io.bassi.Amberol.desktop";
    "inode/directory" = "thunar.desktop";
    "text/x-c" = "code-oss.desktop";
    "application/x-zerosize" = "code-oss.desktop";
    "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    "application/xml" = "code-oss.desktop";
    "video/mp4" = "mpv.desktop";
    "application/vnd.sqlite3" = "code-oss.desktop";
    "application/x-php" = "code-oss.desktop";
    "application/pgp-keys" = "code-oss.desktop";
    "video/x-matroska" = "mpv.desktop";
    "application/x-trash" = "code-oss.desktop";
    "x-scheme-handler/antigravity" = "antigravity.desktop";
  };

  xdg.mimeApps.associations.added = {
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
      "code-oss.desktop"
    ];
    "text/x-lua" = [ "code-oss.desktop" ];
    "text/x-devicetree-source" = [
      "code-oss.desktop"
      "org.x.editor.desktop"
    ];
    "application/x-shellscript" = [
      "org.x.editor.desktop"
      "code-oss.desktop"
    ];
    "text/x-csrc" = [
      "org.x.editor.desktop"
      "code-oss.desktop"
    ];
    "text/x-scss" = [ "org.x.editor.desktop" ];
    "image/svg+xml" = [
      "org.gimp.GIMP.desktop"
      "libreoffice-draw.desktop"
      "org.inkscape.Inkscape.desktop"
    ];
    "application/json" = [ "code-oss.desktop" ];
    "text/x-makefile" = [ "code-oss.desktop" ];
    "audio/x-flac+ogg" = [
      "mpv.desktop"
      "io.bassi.Amberol.desktop"
      "vlc.desktop"
    ];
    "audio/x-vorbis+ogg" = [ "io.bassi.Amberol.desktop" ];
    "application/x-zerosize" = [ "code-oss.desktop" ];
    "application/x-msdownload" = [ "faugus-shortcut.desktop" ];
    "application/xml" = [ "code-oss.desktop" ];
    "video/mp4" = [
      "mpv.desktop"
      "vlc.desktop"
      "DaVinciResolve.desktop"
    ];
    "application/vnd.sqlite3" = [ "code-oss.desktop" ];
    "text/html" = [ "code-oss.desktop" ];
    "application/x-php" = [ "code-oss.desktop" ];
    "inode/directory" = [ "code-oss.desktop" ];
    "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
    "application/pgp-keys" = [ "code-oss.desktop" ];
    "image/gif" = [ "imv.desktop" ];
    "video/quicktime" = [ "vlc.desktop" ];
    "application/x-trash" = [ "code-oss.desktop" ];
  };
}
