{
  description = "Frank's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
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

    # CachyOS kernel + nvidia drivers (linuxPackages_cachyos, nvidia_cachyos),
    # served from the nyx binary cache (see nyx.chaotic.cx).
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      disko,
      nixos-anywhere,
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
      # user: the declarative username; home-manager config is imported from
      #   users/<user>/ and the name is passed to NixOS modules via specialArgs
      #   (modules/nixos/system/users.nix, modules/nixos/tools/sops.nix).
      # profile: "full" (desktop) or "minimal" (console TTY). Injected as the
      #   typed `myProfile` option on both the NixOS and home module systems
      #   (modules/nixos/options.nix, modules/home/options.nix). The raw value
      #   is ALSO passed via specialArgs so `imports` lists can branch on it
      #   (referencing `config` in `imports` is an infinite recursion); all
      #   body gates read the typed config.myProfile.
      # useDiskoMounts: derive fileSystems/swapDevices from the host's disko
      #   layout at build time instead of hardware-configuration.nix (which
      #   install.sh's nixos-anywhere run regenerates UUID-free).
      mkSystem =
        {
          hostDir,
          user,
          profile ? "full",
          useDiskoMounts ? false,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs user profile;
          };

          modules = [
            hostDir
            # Parens required: a formals pattern as a bare list element is
            # ambiguous to the Nix parser (attrset vs function) and fails.
            (
              { ... }:
              {
                config.myProfile = profile;
              }
            )
            (
              { ... }:
              {
                config.home-manager.users.${user}.myProfile = profile;
              }
            )
            # fileSystems/swapDevices come from the disko layout; the
            # regenerated hardware-configuration.nix stays UUID-free.
          ]
          ++ nixpkgs.lib.optionals useDiskoMounts [
            (hostDir + "/disko.nix")
            disko.nixosModules.disko
          ]
          ++ [
            {
              nixpkgs.overlays = [ (import ./overlays) ];
            }

            sops-nix.nixosModules.sops

            chaotic.nixosModules.default

            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = {
                inherit inputs user profile;
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
          useDiskoMounts = true;
        };

        # Console-TTY variant: no display server, Wayland stack, or GUI apps.
        aspire7-min = mkSystem {
          hostDir = ./hosts/aspire7;
          user = "frank";
          profile = "minimal";
          useDiskoMounts = true;
        };

        vm = mkSystem {
          hostDir = ./hosts/vm;
          user = "frank";
          useDiskoMounts = true;
        };

        vm-min = mkSystem {
          hostDir = ./hosts/vm;
          user = "frank";
          profile = "minimal";
          useDiskoMounts = true;
        };
      };

      diskoConfigurations = {
        aspire7 = mkDisko ./hosts/aspire7;
        vm = mkDisko ./hosts/vm;
      };

      apps.${system} = {
        disko = {
          type = "app";
          program = "${disko.packages.${system}.disko}/bin/disko";
        };

        nixos-anywhere = {
          type = "app";
          program = "${nixos-anywhere.packages.${system}.nixos-anywhere}/bin/nixos-anywhere";
        };

        # Pinned tooling for install.sh (avoids resolving from the channel).
        sops = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.sops}/bin/sops";
        };

        ssh-to-age = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.ssh-to-age}/bin/ssh-to-age";
        };

        # Passphrase-encrypted key backup (install/key-backup.sh).
        age = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.age}/bin/age";
        };
      };

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nixfmt
          stylua
          shfmt
          taplo
          shellcheck
        ];
      };
    };
}
