{ pkgs
, host
, ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage;
in
{
  # Styling Options
  stylix = {
    enable = true;
    image = stylixImage;
    base16Scheme = {
      base00 = "111317";
      base01 = "16181d";
      base02 = "1d2128";
      base03 = "2a3039";
      base04 = "6f7782";
      base05 = "e7e1d7";
      base06 = "f2ece2";
      base07 = "fbf7f1";
      base08 = "d17b88";
      base09 = "c98a55";
      base0A = "d9b67a";
      base0B = "9cad8f";
      base0C = "8fb6ad";
      base0D = "c6a36a";
      base0E = "a88db8";
      base0F = "7a5f43";
    };
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
