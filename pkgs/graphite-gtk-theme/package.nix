{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnome-themes-extra,
  gtk-engine-murrine,
  jdupes,
  sassc,
  themeVariants ? [ ],
  colorVariants ? [ ],
  sizeVariants ? [ ],
  tweaks ? [ ],
}:

let
  pname = "graphite-gtk-theme";
in
lib.checkListOfEnum "${pname}: theme variants" [
  "default"
  "purple"
  "pink"
  "red"
  "orange"
  "yellow"
  "green"
  "teal"
  "blue"
  "all"
] themeVariants
lib.checkListOfEnum "${pname}: color variants" [ "standard" "light" "dark" ] colorVariants
lib.checkListOfEnum "${pname}: size variants" [ "standard" "compact" ] sizeVariants
lib.checkListOfEnum "${pname}: tweaks" [
  "nord"
  "black"
  "darker"
  "rimless"
  "normal"
  "float"
  "colorful"
] tweaks

stdenvNoCC.mkDerivation rec {
  inherit pname;
  version = "2024-07-15";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = version;
    hash = "sha256-k93l/7DF0HSKPfiIxzBLz0mBflgbdYJyGLEmWZx3q7o=";
  };

  nativeBuildInputs = [
    jdupes
    sassc
  ];

  buildInputs = [
    gnome-themes-extra
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  installPhase = ''
    runHook preInstall

    patchShebangs install.sh

    name= ./install.sh \
      ${lib.optionalString (themeVariants != [ ]) "--theme " + builtins.toString themeVariants} \
      ${lib.optionalString (colorVariants != [ ]) "--color " + builtins.toString colorVariants} \
      ${lib.optionalString (sizeVariants != [ ]) "--size " + builtins.toString sizeVariants} \
      ${lib.optionalString (tweaks != [ ]) "--tweaks " + builtins.toString tweaks} \
      --dest $out/share/themes

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Flat Gtk+ theme based on Elegant Design";
    homepage = "https://github.com/vinceliuice/Graphite-gtk-theme";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
  };
}
