{ lib, pkgs, ... }:
let
  rofiCommand = lib.optionalString pkgs.stdenv.isLinux ''
      if pidof rofi >/dev/null 2>&1; then
        pkill rofi >/dev/null 2>&1 || true
      fi

      printf '%s\n' "$hosts" | ${pkgs.rofi}/bin/rofi -dmenu -i -config ~/.config/rofi/config-long.rasi -p "Remote host"
      return
  '';

  notifyCommand =
    if pkgs.stdenv.isDarwin then
      ''/usr/bin/osascript -e "display notification \"$1\" with title \"Remote Neovide\"" >/dev/null 2>&1 || true''
    else
      ''${pkgs.libnotify}/bin/notify-send "Remote Neovide" "$1" >/dev/null 2>&1 || true'';

  remote-neovide = pkgs.writeShellScriptBin "remote-neovide" ''
    set -eu

    workspace_file="''${XDG_DATA_HOME:-$HOME/.local/share}/nvim/remote-nvim.nvim/workspace.json"
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/remote-neovide"
    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/remote-neovide"
    nvim_config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    nvim_init_file="$nvim_config_dir/init.lua"
    remote_neovide_lua="$nvim_config_dir/lua/config/remote_neovide.lua"

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
      ${notifyCommand}
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

      ${rofiCommand}

      ${lib.optionalString pkgs.stdenv.isDarwin ''
      if [ ! -t 0 ] || [ ! -t 1 ]; then
        choice="$(/usr/bin/osascript \
          -e 'on run argv' \
          -e 'set hostList to paragraphs of (item 1 of argv)' \
          -e 'try' \
          -e 'set chosenHost to choose from list hostList with title "Remote Neovide" with prompt "Choose a remote host:"' \
          -e 'on error' \
          -e 'return ""' \
          -e 'end try' \
          -e 'if chosenHost is false then' \
          -e 'return ""' \
          -e 'end if' \
          -e 'return item 1 of chosenHost' \
          -e 'end run' \
          "$hosts" 2>/dev/null)"
        printf '%s\n' "$choice"
        return
      fi
      ''}

      if [ -t 0 ] && [ -t 1 ]; then
        printf '%s\n' "$hosts" | ${pkgs.fzf}/bin/fzf --prompt="Remote host> "
        return
      fi

      printf '%s\n' "$hosts" >&2
      notify_error "Pass a host explicitly, for example: remote-neovide my-desktop"
      exit 1
    }

    sanitize_host() {
      printf '%s' "$1" | tr -c '[:alnum:]._-' '_'
    }

    ensure_workspace_host() {
      mkdir -p "$(dirname "$workspace_file")"

      if [ ! -s "$workspace_file" ]; then
        printf '{}\n' > "$workspace_file"
      fi

      if ! ${pkgs.jq}/bin/jq -e --arg host "$host" 'has($host)' "$workspace_file" >/dev/null 2>&1; then
        tmp_file="$workspace_file.tmp.$$"
        ${pkgs.jq}/bin/jq \
          --arg host "$host" \
          '. + {($host): {provider: "ssh", host: $host, connection_options: ""}}' \
          "$workspace_file" > "$tmp_file"
        mv "$tmp_file" "$workspace_file"
      fi
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
    ensure_workspace_host

    if [ ! -f "$nvim_init_file" ]; then
      echo "remote-neovide: missing nvim init file: $nvim_init_file" >&2
      exit 1
    fi

    if [ ! -f "$remote_neovide_lua" ]; then
      echo "remote-neovide: missing remote neovide module: $remote_neovide_lua" >&2
      exit 1
    fi

    # True as soon as the local coordinator nvim process is up, regardless of
    # whether its remote-nvim.nvim session is actually still connected.
    is_local_running() {
      nvim --server "$control_socket" --remote-expr "1" >/dev/null 2>&1
    }

    # True only if the local coordinator is up AND remote-nvim.nvim still
    # considers its remote server session alive. A local coordinator can
    # outlive a dropped SSH/remote connection (e.g. network blip, remote
    # crash), leaving a "zombie" session that responds locally but will never
    # do anything useful again. Checking remote-nvim.nvim's own session state
    # (rather than just the local socket) lets `start` detect that and
    # transparently clean up + reconnect instead of reporting false "already
    # running" forever.
    is_running() {
      is_local_running || return 1

      result="$(nvim --server "$control_socket" --remote-expr "luaeval('(function() local ok, rn = pcall(require, \"remote-nvim\"); if not ok then return 0 end; local s = rn.session_provider:get_session(vim.env.REMOTE_NVIM_HOST); if s == nil then return 0 end; local ok2, running = pcall(function() return s:is_remote_server_running() end); if not (ok2 and running) then return 0 end; return 1 end)()')" 2>/dev/null)"
      [ "$result" = "1" ]
    }

    kill_stale_session() {
      if is_local_running; then
        echo "remote-neovide: cleaning up stale session for $host" >&2
        pkill -f "nvim --listen $control_socket" >/dev/null 2>&1 || true
        sleep 0.3
      fi
    }

    wait_for_server() {
      count=0
      while [ "$count" -lt 150 ]; do
        if [ -S "$control_socket" ]; then
          return 0
        fi
        if is_local_running; then
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

        kill_stale_session

        if [ -S "$control_socket" ] || [ -e "$control_socket" ]; then
          rm -f "$control_socket"
        fi

        REMOTE_NVIM_NEOVIDE_DETACH=1 REMOTE_NVIM_HOST="$host" nohup \
          nvim --listen "$control_socket" --headless -u "$nvim_init_file" -i NONE \
          "+lua (assert(dofile([[''${remote_neovide_lua}]]))).start_from_env()" \
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
        if is_running; then
          nvim --server "$control_socket" --remote-send "<Cmd>RemoteStop $host<CR><Cmd>qall!<CR>"
          echo "remote-neovide: stopping $host"
        elif is_local_running; then
          kill_stale_session
          echo "remote-neovide: $host was a stale session, cleaned up"
        else
          echo "remote-neovide: $host is not running"
          exit 1
        fi
        ;;
      status)
        if is_running; then
          echo "remote-neovide: $host is running"
          echo "socket: $control_socket"
          echo "log: $log_file"
          exit 0
        fi

        if is_local_running; then
          echo "remote-neovide: $host has a stale local session (remote link dead)"
          echo "socket: $control_socket"
          echo "log: $log_file"
          exit 1
        fi

        echo "remote-neovide: $host is not running"
        exit 1
        ;;
    esac
  '';

  remoteNeovideApp = pkgs.runCommand "remote-neovide-app" { } ''
    app_dir="$out/Remote Neovide.app"
    mkdir -p "$app_dir/Contents/MacOS"

    cat > "$app_dir/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Remote Neovide</string>
  <key>CFBundleDisplayName</key>
  <string>Remote Neovide</string>
  <key>CFBundleIdentifier</key>
  <string>dev.ownvoy.remote-neovide</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleExecutable</key>
  <string>remote-neovide-launcher</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSUIElement</key>
  <true/>
  <key>LSMinimumSystemVersion</key>
  <string>10.13</string>
</dict>
</plist>
PLIST

    cat > "$app_dir/Contents/MacOS/remote-neovide-launcher" <<LAUNCHER
#!/bin/sh
# GUI-launched apps (Finder/Spotlight/Launchpad) get a minimal PATH that is
# missing nvim (nix-darwin) and neovide (Homebrew cask). Shell rc files are
# not a reliable fix (Homebrew's shellenv usually only loads for interactive
# shells), so prepend the known locations directly instead.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:\$HOME/.nix-profile/bin:/etc/profiles/per-user/\$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:\$PATH"
exec "${remote-neovide}/bin/remote-neovide" "\$@"
LAUNCHER
    chmod +x "$app_dir/Contents/MacOS/remote-neovide-launcher"
  '';
in
{
  home.packages = [ remote-neovide ];

  xdg.desktopEntries.remote-neovide = lib.mkIf pkgs.stdenv.isLinux {
    name = "Remote Neovide";
    comment = "Pick a remote.nvim host and open it in Neovide";
    exec = "remote-neovide";
    icon = "nvim";
    terminal = false;
    type = "Application";
    categories = [ "Development" "Network" ];
  };

  home.activation.installRemoteNeovideApp = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_src="${remoteNeovideApp}/Remote Neovide.app"
      app_dest="$HOME/Applications/Remote Neovide.app"
      mkdir -p "$HOME/Applications"
      if [ -e "$app_dest" ]; then
        chmod -R u+w "$app_dest" 2>/dev/null || true
        rm -rf "$app_dest"
      fi
      /usr/bin/ditto "$app_src" "$app_dest"
      chmod -R u+w "$app_dest"
      /usr/bin/xattr -dr com.apple.quarantine "$app_dest" 2>/dev/null || true
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app_dest" >/dev/null 2>&1 || true
    ''
  );
}
