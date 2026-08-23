{ config, lib, ... }:

let
  colors = (config.lib.stylix or { }).colors.withHashtag or { };
in
{
  programs.cava = {
    enable = true;

    settings = lib.optionalAttrs (colors != { }) {
      color = {
        gradient = 1;
        gradient_color_1 = "'${colors.base04}'";
        gradient_color_2 = "'${colors.base05}'";
        gradient_color_3 = "'${colors.base06}'";
        gradient_color_4 = "'${colors.base07}'";
        gradient_color_5 = "'${colors.base08}'";
        gradient_color_6 = "'${colors.base09}'";
        gradient_color_7 = "'${colors.base0A}'";
        gradient_color_8 = "'${colors.base0F}'";
      };
    };
  };
}
