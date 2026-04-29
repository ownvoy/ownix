{ inputs, lib, username, host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) terminal;
  settings = lib.foldl' lib.recursiveUpdate { } [
    (import ./app-launcher-audio.nix { inherit terminal; })
    (import ./bar.nix)
    (import ./control-center.nix)
    (import ./desktop-dock.nix)
    (import ./general-ui.nix { inherit username; })
    (import ./notifications-session.nix)
    (import ./wallpaper.nix { inherit username; })
  ];
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    inherit settings;
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        clipper = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };
}
