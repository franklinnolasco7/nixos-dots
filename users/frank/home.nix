{ ... }:

{
  imports = [
    ../../modules/home
  ];

  home.username = "frank";
  home.homeDirectory = "/home/frank";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
