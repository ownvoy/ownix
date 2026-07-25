{ pkgs }:
pkgs.writeShellScriptBin "start-noctalia-shell" ''
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop waybar.service >/dev/null 2>&1 || true
    systemctl --user stop swaync.service >/dev/null 2>&1 || true
    systemctl --user mask swaync.service >/dev/null 2>&1 || true
  fi

  pkill -x waybar >/dev/null 2>&1 || true
  pkill -x swaync >/dev/null 2>&1 || true

  # noctalia v5 ships a single `noctalia` binary (was `noctalia-shell` in v4).
  # Its wrapped process comm is `.noctalia-wrapp`, so match the cmdline path
  # end instead of `pgrep -x noctalia` (which never matches the wrapper).
  if ! pgrep -f 'noctalia$' >/dev/null 2>&1; then
    noctalia >/dev/null 2>&1 &
  fi
''
