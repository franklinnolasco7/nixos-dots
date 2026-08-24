final: prev: {
  graphite-gtk-theme = final.callPackage ../pkgs/graphite-gtk-theme/package.nix { };

  codeburn = final.callPackage ../pkgs/codeburn/package.nix { };

  # Drop once nixpkgs' vesktop builds against an Electron that keeps the Linux
  # tray alive: >= 43.3 stopped registering StatusNotifierItems, so upstream
  # pinned 43.2.0 as the fix
  # (https://github.com/Vencord/Vesktop/commit/c9ded5c658a57d61abbdb608b7c6cedc9ed2c060).
  # nixpkgs only exposes one Electron per major (currently 43.4.1), so swap to
  # the cached 42.x and strip the expression's major-mismatch guard.
  vesktop = (prev.vesktop.override { electron_43 = final.electron_42; }).overrideAttrs (_: {
    preBuild = ''
      cp -r ${final.electron_42.dist} electron-dist
      chmod -R u+w electron-dist
    '';
  });
}
