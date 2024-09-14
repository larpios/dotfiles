{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
        url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
  let
      name = "ray";
  in
  {
    homeConfigurations = {
        "${name}@linux" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
                ./home.nix
                ./linux.nix
            ];
            extraSpecialArgs = {
                userConfig = {
                    inherit name;
                    home = "/home/${name}";
                };
            };
        };
        "${name}@darwin" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-darwin;
            modules = [
                ./home.nix
                ./darwin.nix
            ];
            extraSpecialArgs = {
                userConfig = {
                    inherit name;
                    home = "/Users/${name}";
                };
            };
        };

    };

  };
}
