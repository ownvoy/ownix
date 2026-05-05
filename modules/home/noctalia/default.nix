{ config, inputs, lib, pkgs, username, host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    desktopShell
    terminal
    ;
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

  home.file.".config/noctalia/plugins/todo" = {
    source = ./plugins/todo;
    recursive = true;
  };

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
        todo = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };

  home.activation.reloadNoctaliaShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ "${desktopShell}" != "noctalia" ]; then
      exit 0
    fi

    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      exit 0
    fi

    if ! ${pkgs.procps}/bin/pgrep -x Hyprland >/dev/null 2>&1; then
      exit 0
    fi

    if ! ${pkgs.procps}/bin/pgrep -x noctalia-shell >/dev/null 2>&1; then
      exit 0
    fi

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

    ${config.home.profileDirectory}/bin/start-noctalia-shell >/dev/null 2>&1 || true
  '';
}
