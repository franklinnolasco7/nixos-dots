final: prev: {
  graphite-gtk-theme = final.callPackage ../pkgs/graphite-gtk-theme/package.nix { };

  codeburn = final.callPackage ../pkgs/codeburn/package.nix { };

  # Drop once nixpkgs' vesktop stops building against a tray-broken
  # Electron: >= 43.3 no longer registers StatusNotifierItems, so the
  # Linux tray icon vanishes. Upstream pinned 43.2.0 as the fix
  # (https://github.com/Vencord/Vesktop/commit/c9ded5c658a57d61abbdb608b7c6cedc9ed2c060),
  # but nixpkgs only exposes one Electron per major, so we swap to the
  # cached 42.x and strip the expression's major-mismatch guard.
  vesktop = (prev.vesktop.override { electron_43 = final.electron_42; }).overrideAttrs (old: rec {
    version = "1.6.7";
    src = final.fetchFromGitHub {
      owner = "Vencord";
      repo = "Vesktop";
      rev = "v1.6.7";
      hash = "sha256-Y74FIqcY26Dizz+DoY+r8caOfX+4/VmiEbmhcOpMHqE=";
    };
    pnpmDeps = final.fetchPnpmDeps {
      inherit (old) pname;
      inherit version src;
      pnpm = final.pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-AK+ZbylpG7iKWKsIA0nfFfZYP7HaTCTSeDbNUFx/iY4=";
    };
    # nixpkgs' guard rejects Electron majors != upstream's pin (43);
    # keep its dist-copy step against our swapped-in 42.x instead.
    preBuild = ''
      cp -r ${final.electron_42.dist} electron-dist
      chmod -R u+w electron-dist
    '';
  });
}
