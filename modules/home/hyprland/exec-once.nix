{ host, ... }:
let
  inherit
    (import ../../../hosts/${host}/variables.nix)
    desktopShell
    stylixImage
    ;
  shellStartup =
    if desktopShell == "noctalia" then
      "start-noctalia-shell"
    else
      "start-classic-shell";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "wl-paste --type text --watch cliphist store" # Saves text
      "wl-paste --type image --watch cliphist store" # Saves images
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user start hyprpolkitagent"

      "killall -q swww;sleep .5 && swww-daemon"
      shellStartup
      "#wallsetter &"
      "nm-applet --indicator"
      "sleep 1.0 && swww img ${stylixImage}"
      "sleep 2.0 && cava-bg off >/dev/null 2>&1; sleep .2 && cava-bg on"
      "fcitx5 -d -r"
    ];
  };
}
