{
  description = "Frank's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";
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

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hyprland,
      disko,
      home-manager,
      sops-nix,
      chaotic,
      ...
    }:
    let
      system = "x86_64-linux";

      # Build a NixOS configuration for a host.
      #
      # hostDir: path to hosts/<name>/ (hardware-configuration.nix,
      #   disko.nix, configuration.nix).
      # user: the declarative username — home-manager config is imported from
      #   users/<user>/ and the name is passed to NixOS modules via specialArgs
      #   (modules/nixos/system/users.nix, modules/nixos/tools/sops.nix).
      mkSystem =
        {
          hostDir,
          user,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs user;
          };

          modules = [
            hostDir
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
                inherit inputs user;
              };

              home-manager.users.${user} = import ./users/${user}/default.nix;
            }
          ];
        };

      mkDisko = hostDir: {
        modules = [
          (hostDir + "/disko.nix")
        ];
      };
    in
    {
      nixosConfigurations = {
        aspire7 = mkSystem {
          hostDir = ./hosts/aspire7;
          user = "frank";
        };

        vm = mkSystem {
          hostDir = ./hosts/vm;
          user = "frank";
        };
      };

      diskoConfigurations = {
        aspire7 = mkDisko ./hosts/aspire7;
        vm = mkDisko ./hosts/vm;
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
