{
  lib,
  buildNpmPackage,
  fetchzip,
  fetchurl,
  fetchNpmDeps,
}:

buildNpmPackage rec {
  pname = "codeburn";
  version = "0.9.20";

  src = fetchzip {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-rjXpFz5DWfbWdCpFOXJ4vQJTVMnd9qRJOENprl0ev5k=";
  };

  npmLockfile = fetchurl {
    url = "https://raw.githubusercontent.com/getagentseal/codeburn/v${version}/package-lock.json";
    hash = "sha256-Piw7k6twNMzQ09tJFM43h23n96eqgNArOH7pCaH2YPY=";
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-t36Q1NLjY0I//m/XJrPdxe0a6LvYqgY5+HOphMzlE5M=";
    postPatch = ''
      cp ${npmLockfile} package-lock.json
    '';
  };

  postPatch = ''
    cp ${npmLockfile} package-lock.json
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "Free, local tool to track AI coding token usage and cost across 37 tools and agents (Claude Code, Cursor, Codex, Gemini and more), by model, project, and task.";
    homepage = "https://github.com/getagentseal/codeburn";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "codeburn";
  };
}
