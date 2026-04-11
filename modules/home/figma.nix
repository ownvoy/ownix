{ config, pkgs, ... }:

{
  # 1. Allow unfree packages (if you haven't already)
  nixpkgs.config.allowUnfree = true;

  # 2. REQUIRED: Create the standard font directory so Figma can see them
  fonts.fontDir.enable = true;

  # 3. Install Fonts & Figma Agent
  home.packages= with pkgs; [
    figma-linux
  ];

  fonts.packages = with pkgs; [
    corefonts
    vistafonts
  ];
}
