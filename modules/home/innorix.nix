{ config, lib, pkgs, ... }:
let
  installDir = "${config.home.homeDirectory}/.local/share/innorix-agent";
  wrapperPath = "${config.home.profileDirectory}/bin/innorixas";
  defaultDeb = "${config.home.homeDirectory}/Downloads/INNORIX-Agent-22.04.deb";
  altDeb = "${config.home.homeDirectory}/Downloads/INNORIX-Agent-22.04 (1).deb";
  runtimeLibs = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.glib
    pkgs.gtk2
    pkgs.at-spi2-core
    pkgs.cairo
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.fontconfig.lib
    pkgs.freetype
    pkgs.libpng
    pkgs.libjpeg8
    pkgs.harfbuzz
    pkgs.expat
    pkgs.zlib
    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.xorg.libXrender
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libXcursor
    pkgs.xorg.libXinerama
    pkgs.xorg.libXcomposite
    pkgs.xorg.libXdamage
    pkgs.xorg.libXfixes
    pkgs.xorg.libxcb
    pkgs.xorg.libXau
    pkgs.xorg.libXdmcp
    pkgs.libxkbcommon
    pkgs.nspr
    pkgs.nss
  ];
  innorixWrapper = pkgs.writeShellApplication {
    name = "innorixas";
    runtimeInputs = with pkgs; [
      bubblewrap
      coreutils
      findutils
      gnugrep
      procps
      python3
    ];
    text = ''
      set -euo pipefail

      INSTALL_DIR="${installDir}"
      PID_FILE="$INSTALL_DIR/innorixas.pid"
      TRAY_FILE="$HOME/InnorixTray"

      rewrite_configs() {
        python3 - <<'PY'
import json
import os
from pathlib import Path

install_dir = Path(os.path.expanduser("${installDir}"))

server = install_dir / "server.conf"
if server.exists():
    data = json.loads(server.read_text())
    data["dest_path"] = str(install_dir / "dest")
    data["orig_path"] = str(install_dir / "orig")
    server.write_text(json.dumps(data, indent=3) + "\n")

cfg = install_dir / "innorixas.conf"
if cfg.exists():
    data = json.loads(cfg.read_text())
    data["innorixas_path"] = str(install_dir)
    cfg.write_text(json.dumps(data, indent=4) + "\n")
PY
      }

      import_certificates() {
        local certificate_file="$INSTALL_DIR/ca.crt"
        local certificate_name="INNORIX"
        local cert_db cert_dir

        while IFS= read -r cert_db; do
          cert_dir="$(dirname "$cert_db")"
          "$INSTALL_DIR/certutil" -A -n "$certificate_name" -t "TC,Cw,Tw" -i "$certificate_file" -d "sql:$cert_dir" || true
          "$INSTALL_DIR/certutil" -A -n "$certificate_name" -t "TC,Cw,Tw" -i "$certificate_file" -d "$cert_dir" || true
        done < <(find "$HOME"/.mozilla* -name "cert8.db" 2>/dev/null)

        while IFS= read -r cert_db; do
          cert_dir="$(dirname "$cert_db")"
          "$INSTALL_DIR/certutil" -A -n "$certificate_name" -t "TC,Cw,Tw" -i "$certificate_file" -d "sql:$cert_dir" || true
        done < <(find "$HOME"/.mozilla* "$HOME"/snap/firefox/common/.mozilla/firefox* "$HOME"/.pki/nssdb -name "cert9.db" 2>/dev/null)

        while IFS= read -r cert_db; do
          cert_dir="$(dirname "$cert_db")"
          "$INSTALL_DIR/certutil" -A -n "$certificate_name" -t "TC,Cw,Tw" -i "$certificate_file" -d "sql:$cert_dir" || true
        done < <(find "$HOME"/.thunderbird -name "cert8.db" 2>/dev/null)
      }

      run_agent() {
        bwrap \
          --tmpfs / \
          --ro-bind /nix /nix \
          --ro-bind /etc /etc \
          --ro-bind /sys /sys \
          --dev-bind /dev /dev \
          --proc /proc \
          --bind "$HOME" "$HOME" \
          --bind /run /run \
          --bind /tmp /tmp \
          --dir /opt \
          --bind "$INSTALL_DIR" /opt/innorix-agent \
          --chdir /opt/innorix-agent \
          /opt/innorix-agent/innorixas.bin "$1"
      }

      start_agent() {
        rewrite_configs
        import_certificates

        if pgrep -f 'innorixas.bin' >/dev/null; then
          exit 0
        fi

        rm -f "$PID_FILE"
        if ! pgrep -f 'innorixst.bin' >/dev/null; then
          rm -f "$TRAY_FILE"
        fi

        (
          run_agent start
        ) >/dev/null 2>&1 &
      }

      stop_agent() {
        if pgrep -f 'innorixas.bin' >/dev/null; then
          (
            run_agent stop
          ) >/dev/null 2>&1 &
        fi
      }

      case "''${1:-}" in
        start)
          start_agent
          ;;
        stop)
          stop_agent
          ;;
        *)
          echo "Usage: $0 {start|stop}" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    innorixWrapper
    binutils
    bubblewrap
    patchelf
    zstd
  ];

  xdg.desktopEntries.innorix-agent = {
    name = "innorix-agent";
    comment = "innorix-agent starter";
    exec = "${wrapperPath} start";
    type = "Application";
    terminal = false;
    settings = {
      Hidden = "false";
      NoDisplay = "false";
      X-GNOME-Autostart-enabled = "true";
      "Name[ko_KR]" = "innorix-agent";
      "Comment[ko_KR]" = "innorix-agent starter";
    };
  };

  home.file.".config/autostart/innorix-agent.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=${wrapperPath} start
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[ko_KR]=innorix-agent
    Name=innorix-agent
    Comment[ko_KR]=innorix-agent starter
    Comment=innorix-agent starter
  '';

  home.file.".local/bin/innorixas" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec ${wrapperPath} "$@"
    '';
  };

  home.activation.installInnorix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    install_dir="${installDir}"
    cache_dir="$HOME/.cache/innorix-agent-build"
    marker_file="$install_dir/.deb-sha256"
    deb_path=""

    if [ -f "${defaultDeb}" ]; then
      deb_path="${defaultDeb}"
    elif [ -f "${altDeb}" ]; then
      deb_path="${altDeb}"
    fi

    if [ -z "$deb_path" ]; then
      if [ ! -d "$install_dir" ]; then
        echo "INNORIX: missing .deb file in ~/Downloads; skipping install" >&2
      fi
    else
      mkdir -p "$install_dir" "$cache_dir"
      deb_sha="$(${pkgs.coreutils}/bin/sha256sum "$deb_path" | ${pkgs.coreutils}/bin/cut -d' ' -f1)"

      if [ ! -f "$marker_file" ] || [ "$(${pkgs.coreutils}/bin/cat "$marker_file")" != "$deb_sha" ]; then
        rm -rf "$cache_dir"/*
        mkdir -p "$cache_dir/extract" "$cache_dir/unpack"

        cd "$cache_dir/extract"
        ${pkgs.binutils}/bin/ar x "$deb_path"
        ${pkgs.gnutar}/bin/tar --zstd -xf data.tar.zst -C "$cache_dir/unpack"

        rm -rf "$install_dir"
        mkdir -p "$install_dir"
        cp -a "$cache_dir/unpack/opt/innorix-agent/." "$install_dir/"

        for bin in "$install_dir/innorixas.bin" "$install_dir/innorixst.bin" "$install_dir/certutil"; do
          ${pkgs.patchelf}/bin/patchelf \
            --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} \
            --set-rpath '${runtimeLibs}' \
            "$bin"
        done

        ${pkgs.python3}/bin/python3 - <<PY
import json
from pathlib import Path

install_dir = Path("${installDir}")

server = install_dir / "server.conf"
data = json.loads(server.read_text())
data["dest_path"] = str(install_dir / "dest")
data["orig_path"] = str(install_dir / "orig")
server.write_text(json.dumps(data, indent=3) + "\n")

cfg = install_dir / "innorixas.conf"
data = json.loads(cfg.read_text())
data["innorixas_path"] = str(install_dir)
cfg.write_text(json.dumps(data, indent=4) + "\n")
PY

        printf '%s\n' "$deb_sha" > "$marker_file"
      fi
    fi
  '';
}
