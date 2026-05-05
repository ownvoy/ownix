{ pkgs, ... }:
let
  remote-neovide = pkgs.writeShellScriptBin "remote-neovide" ''
    set -eu

    workspace_file="''${XDG_DATA_HOME:-$HOME/.local/share}/nvim/remote-nvim.nvim/workspace.json"
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/remote-neovide"
    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/remote-neovide"

    usage() {
      cat <<'EOF'
Usage:
  remote-neovide
  remote-neovide <host>
  remote-neovide start <host>
  remote-neovide stop <host>
  remote-neovide status <host>
EOF
    }

    notify_error() {
      ${pkgs.libnotify}/bin/notify-send "Remote Neovide" "$1" >/dev/null 2>&1 || true
    }

    choose_host() {
      if [ ! -f "$workspace_file" ]; then
        notify_error "No remote.nvim workspace list found yet."
        exit 1
      fi

      hosts="$(
        ${pkgs.jq}/bin/jq -r 'keys[]' "$workspace_file" 2>/dev/null | while IFS= read -r host; do
          safe_host="$(sanitize_host "$host")"
          host_log="$state_dir/$safe_host.log"
          if [ -f "$host_log" ]; then
            mtime="$(${pkgs.coreutils}/bin/stat -c %Y "$host_log" 2>/dev/null || echo 0)"
          else
            mtime=0
          fi
          printf '%s\t%s\n' "$mtime" "$host"
        done | ${pkgs.coreutils}/bin/sort -rn -k1,1 | ${pkgs.gawk}/bin/awk -F '\t' '{print $2}'
      )"
      if [ -z "$hosts" ]; then
        notify_error "No saved remote.nvim hosts found."
        exit 1
      fi

      if pidof rofi >/dev/null 2>&1; then
        pkill rofi >/dev/null 2>&1 || true
      fi

      printf '%s\n' "$hosts" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -config ~/.config/rofi/config-long.rasi -p "Remote host"
    }

    sanitize_host() {
      printf '%s' "$1" | tr -c '[:alnum:]._-' '_'
    }

    subcommand="start"
    case "''${1:-}" in
      "" )
        host="$(choose_host)"
        [ -n "$host" ] || exit 0
        ;;
      start|stop|status)
        subcommand="$1"
        shift
        host="''${1:-}"
        ;;
      * )
        host="$1"
        ;;
    esac

    if [ -z "''${host:-}" ]; then
      usage
      exit 1
    fi

    safe_host="$(sanitize_host "$host")"
    control_socket="$runtime_dir/$safe_host.sock"
    log_file="$state_dir/$safe_host.log"

    mkdir -p "$runtime_dir" "$state_dir"

    is_running() {
      nvim --server "$control_socket" --remote-expr "1" >/dev/null 2>&1
    }

    wait_for_server() {
      count=0
      while [ "$count" -lt 150 ]; do
        if [ -S "$control_socket" ]; then
          return 0
        fi
        if is_running; then
          return 0
        fi
        sleep 0.1
        count=$((count + 1))
      done
      return 1
    }

    case "$subcommand" in
      start)
        if is_running; then
          echo "remote-neovide: $host is already running"
          exit 0
        fi

        if [ -S "$control_socket" ] || [ -e "$control_socket" ]; then
          rm -f "$control_socket"
        fi

        REMOTE_NVIM_NEOVIDE_DETACH=1 REMOTE_NVIM_HOST="$host" nohup \
          nvim --listen "$control_socket" --headless -i NONE \
          '+lua require("config.remote_neovide").start_from_env()' \
          >>"$log_file" 2>&1 </dev/null &

        if wait_for_server; then
          echo "remote-neovide: started $host"
          echo "log: $log_file"
          exit 0
        fi

        echo "remote-neovide: failed to start $host" >&2
        echo "log: $log_file" >&2
        notify_error "Failed to start $host. Check $log_file"
        exit 1
        ;;
      stop)
        if ! is_running; then
          echo "remote-neovide: $host is not running"
          exit 1
        fi

        nvim --server "$control_socket" --remote-send "<Cmd>RemoteStop $host<CR><Cmd>qaall!<CR>"
        echo "remote-neovide: stopping $host"
        ;;
      status)
        if is_running; then
          echo "remote-neovide: $host is running"
          echo "socket: $control_socket"
          echo "log: $log_file"
          exit 0
        fi

        echo "remote-neovide: $host is not running"
        exit 1
        ;;
    esac
  '';
in
{
  home.packages = [ remote-neovide ];

  xdg.desktopEntries.remote-neovide = {
    name = "Remote Neovide";
    comment = "Pick a remote.nvim host and open it in Neovide";
    exec = "remote-neovide";
    icon = "nvim";
    terminal = false;
    type = "Application";
    categories = [ "Development" "Network" ];
  };
}
