{ pkgs }:
pkgs.writeShellScriptBin "start-classic-shell" ''
  pkill -x noctalia-shell >/dev/null 2>&1 || true

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user unmask swaync.service >/dev/null 2>&1 || true
    systemctl --user restart waybar.service >/dev/null 2>&1 || true
    systemctl --user restart swaync.service >/dev/null 2>&1 || true
  fi

  if ! pgrep -x waybar >/dev/null 2>&1; then
    waybar >/dev/null 2>&1 &
  fi

  if ! pgrep -x swaync >/dev/null 2>&1; then
    swaync >/dev/null 2>&1 &
  fi
''
