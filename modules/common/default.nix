{ config, pkgs, ... }:

{

  # Enable the use of flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  programs.thunar.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.xfconf.enable = true;
  programs.obs-studio.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.gnupg.agent = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    slurp
    elmerfem
    anki
    spotify
    gparted
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."lukas" = {
    isNormalUser = true;
    description = "Lukas";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    packages = with pkgs; [ ];
  };
}
