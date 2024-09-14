{ config, lib, pkgs, userConfig, ... }@inputs:
{
    home.packages = with pkgs; [
        xcode-install
    ];
  programs = {
    zsh = {
      shellAliases = {
      };
    };
  };
  home.shellAliases = {
    home-update = "nix run home-manager/master switch -- -b backup --flake ~/.dotfiles/flakes/home#ray@darwin";
  };
}
