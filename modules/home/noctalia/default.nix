{ config, inputs, lib, pkgs, username, host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    desktopShell
    ;
  settings = import ./settings.nix { inherit username; };
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.system}.default;
    # We hand-migrated this config to the v5 TOML schema. Build-time validation
    # runs `noctalia config validate`; flip to true once the config is settled.
    validateConfig = false;
    # stylix's noctalia target also injects settings (opacity/fonts); mkForce so
    # our explicit config wins and avoids conflicting-definition errors.
    settings = lib.mkForce settings;
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

    # v5's wrapped comm is `.noctalia-wrapp`; match the cmdline path end
    # instead of `pgrep -x noctalia` (which never matches the wrapper).
    if ! ${pkgs.procps}/bin/pgrep -f 'noctalia$' >/dev/null 2>&1; then
      exit 0
    fi

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

    ${config.home.profileDirectory}/bin/start-noctalia-shell >/dev/null 2>&1 || true
  '';
}
