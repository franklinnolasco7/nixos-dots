final: prev: {
  graphite-gtk-theme = final.callPackage ../pkgs/graphite-gtk-theme/package.nix { };

  codeburn = final.callPackage ../pkgs/codeburn/package.nix { };
}
