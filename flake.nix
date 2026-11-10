{
  description = "NixOS configuration";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs =
    {
      self,
      stable,
      unstable,
      sops-nix,
      nixos-hardware,
      ...
    }@inputs:
    let
      mkHost =
        {
          name,
          nixpkgs ? unstable,
          modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs self;
            flakeRoot = self.outPath;
          };
          modules = [ ./hosts/${name} ] ++ modules;
        };
    in
    {
      nixosConfigurations = {
        longitude = mkHost {
          name = "longitude";
          modules = [ ./modules/home-manager ];
        };
        arnold = mkHost {
          name = "arnold";
          modules = [ ./modules/home-manager ];
        };
        fw = mkHost {
          name = "fw";
          modules = [
            ./modules/home-manager
            sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };
        fractal = mkHost {
          name = "fractal";
          nixpkgs = stable;
        };
      };
    };
}
