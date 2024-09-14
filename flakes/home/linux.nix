{ config, pkgs, ... }:

{
    home.packages = with pkgs; [
        neovide
    ];
    programs = {
    	zsh = {
		shellAliases = {
			home-update = "nix run home-manager/master switch -b backup -- --flake ~/.dotfiles/flakes/home#ray@darwin";
		};
	};
    };
}

