{ pkgs }:
pkgs.writeShellScriptBin "start-noctalia-shell" ''
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop waybar.service >/dev/null 2>&1 || true
    systemctl --user stop swaync.service >/dev/null 2>&1 || true
    systemctl --user mask swaync.service >/dev/null 2>&1 || true
  fi

  pkill -x waybar >/dev/null 2>&1 || true
  pkill -x swaync >/dev/null 2>&1 || true

  if ! pgrep -x noctalia-shell >/dev/null 2>&1; then
    noctalia-shell >/dev/null 2>&1 &
  fi
''
