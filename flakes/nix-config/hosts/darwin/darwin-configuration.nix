{ config, pkgs, username, system, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    wget
    curl
  ];

  system.defaults.dock = {
    autohide = true;
    orientation = "bottom";
    showhidden = true;

  };
  security.pam.enableSudoTouchIdAuth = true;


  # Auto upgrade nix packages and the demon service.
  services.nix-daemon.enable = true;
  homebrew = {
    enable = true;
    brews = [
      "krita-beta"
    ];
  };
  system.stateVersion = 5;
}
