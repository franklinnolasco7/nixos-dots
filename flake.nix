{
  description = "Frank's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    hyprland.url = "github:hyprwm/Hyprland";
    # NOTE: Intentionally not following nixpkgs — Hyprland pins its own for ABI compatibility.

    # TEMP WORKAROUND: waybar master until a release ships the Hyprland Lua
    # IPC fix (PR #5013, commit e17c0d9). Revert to pkgs.waybar once nixpkgs
    # has waybar >= 0.15.1. Remove this input then.
    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    hyprland,
    disko,
    home-manager,
    sops-nix,
    ...
  }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.aspire7 = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./hosts/aspire7/default.nix

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit inputs;
          };

          home-manager.users.frank = import ./users/frank/default.nix;
        }
      ];
    };

    diskoConfigurations.aspire7 = {
      modules = [
        ./hosts/aspire7/disko.nix
      ];
    };

    apps.${system}.disko = {
      type = "app";
      program = "${disko.packages.${system}.disko}/bin/disko";
    };

    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      packages = with nixpkgs.legacyPackages.${system}; [
        nixfmt
        stylua
        shfmt
        taplo
      ];
    };
  };
}
