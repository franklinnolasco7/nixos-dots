{
  description = "Frank's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # NOTE: Intentionally not following nixpkgs — Hyprland pins its own nixpkgs
    # for reproducible builds and binary-cache hits.

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hyprland,
      hyprland-plugins,
      disko,
      home-manager,
      sops-nix,
      chaotic,
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
          ./hosts/aspire7
          hyprland.nixosModules.default

          {
            nixpkgs.overlays = [ (import ./overlays) ];
          }

          chaotic.nixosModules.default
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
