{ config, pkgs, userConfig, home-manager, ... }:

{
    home.packages = with pkgs; [
        xcode-install
    ];
}
