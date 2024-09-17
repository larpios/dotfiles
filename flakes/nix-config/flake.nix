{
  description = "My Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      username = "ray";
    in
    {
      homeConfigurations."rays-MacBook-Air" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./home/home-ray.nix
        ];
        extraSpecialArgs = { inherit username; };
      };

      darwinConfigurations."rays-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin/darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.ray = import ./home/home-ray.nix;
            };
          }
        ];

        specialArgs = {
          inherit inputs;
        };
      };

    };
  # outputs
}
