#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/innorix-agent"
PID_FILE="${INSTALL_DIR}/innorixas.pid"
TRAY_FILE="${HOME}/InnorixTray"

LINKER="/nix/store/i3ibgfskl99qd8rslafbpaa1dmxdzh1z-glibc-2.40-66/lib/ld-linux-x86-64.so.2"
LIBS="/nix/store/cf1a53iqg6ncnygl698c4v0l8qam5a2q-gcc-14.3.0-lib/lib:/nix/store/sgap1pr1czm1k2pp8sdkp9hs9v3ahx27-glib-2.84.3/lib:/nix/store/w6lfjpwm6g3v0x16zafyic44z3rzq22s-gtk+-2.24.33/lib:/nix/store/h13jrdg1scvfpwmpwdqvd8jmb90gv2z3-at-spi2-core-2.56.2/lib:/nix/store/gd22hvyhpvwpwv3wd3f5r1c02d2cy5m6-cairo-1.18.2/lib:/nix/store/570m5d83a79bcqddf1bq9ac758sgi1j0-pango-1.56.3/lib:/nix/store/zw02m3kb15sb2rs65vjsc81k87xp2pms-gdk-pixbuf-2.42.12/lib:/nix/store/74z7naywq3fzikbsbb0248y7j6mgcmi6-fontconfig-2.16.0-lib/lib:/nix/store/v2nsb0q208p4xiw74vp4srn2sammhhks-freetype-2.13.3/lib:/nix/store/yf40kfs9xqyhzp9h8zrb22arf8vnpksa-libpng-apng-1.6.46/lib:/nix/store/xl73abvrlkpv3d324phskh05lg2v9wnd-libjpeg-turbo-3.0.4/lib:/nix/store/rlxh4fghh2v71s5vvin2slqz2p1kqzwi-harfbuzz-10.2.0/lib:/nix/store/jr8kyv517lyd5xcv3pnhr6z4wirbi06r-expat-2.7.3/lib:/nix/store/f2q5ld1nipl8w1r2w8m6azhlm2varqgb-zlib-1.3.1/lib:/nix/store/2yvh4kwhfd65dcd3r6y6bgdwclfndvzr-libX11-1.8.12/lib:/nix/store/2v2nlnxm34grn5iq1s1n4di9vsn3k4si-libXext-1.3.6/lib:/nix/store/x9agy8k80f2d7qcds6rhrqrv68xqcqiz-libXrender-0.9.12/lib:/nix/store/fxw37cf0j4zp5xagyq0j144536qwc9q4-libXrandr-1.5.4/lib:/nix/store/frfb398wg8imfw5r0ac18gy389by0vap-libXi-1.8.2/lib:/nix/store/c0z5kfib8j6xcmbkdknwkkqy38nwph4c-libXcursor-1.2.3/lib:/nix/store/g7wgcvrsyk0n2fxgmi1ni5lwmq3x23jl-libXinerama-1.1.5/lib:/nix/store/arx565rli278751asv966i4hwb1v71hf-libXcomposite-0.4.6/lib:/nix/store/hs8f4kfqywx5biss84d92i1lwiw49wpk-libXdamage-1.1.6/lib:/nix/store/phrzfhkp7814lxdw46kqsxxxfx6h5f4y-libXfixes-6.0.1/lib:/nix/store/xwd1s74zk3bwilv4p02284ckyy319vhz-libxcb-1.17.0/lib:/nix/store/4gybpyd4avw8hz8gk0fhhkh2pk06rm6d-libXau-1.0.12/lib:/nix/store/rl14lfb8yhxxajpvlkp7ymvy2gy9f1lk-libXdmcp-1.1.5/lib:/nix/store/ilh3k434j6a9kx8vw4q75k3d2s71q4vw-libxkbcommon-1.8.1/lib:/nix/store/ygcg1n232bpdrx6hgrfjc2pmkjz41nnc-nspr-4.38/lib:/nix/store/aw03p18h49w0z0d8f97bzrd9mkv14jkb-nss-3.101.2/lib"

export LD_LIBRARY_PATH="${INSTALL_DIR}:${LIBS}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export PATH="${INSTALL_DIR}:${PATH}"

run_agent() {
  bwrap \
    --tmpfs / \
    --ro-bind /nix /nix \
    --ro-bind /etc /etc \
    --ro-bind /sys /sys \
    --dev-bind /dev /dev \
    --proc /proc \
    --bind "${HOME}" "${HOME}" \
    --bind /run /run \
    --bind /tmp /tmp \
    --dir /opt \
    --bind "${INSTALL_DIR}" /opt/innorix-agent \
    --chdir /opt/innorix-agent \
    /opt/innorix-agent/innorixas.bin "$1"
}

rewrite_configs() {
  python3 - <<'PY'
import json
import os
from pathlib import Path

install_dir = Path(os.path.expanduser("~/.local/share/innorix-agent"))

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
  local certificate_file="${INSTALL_DIR}/ca.crt"
  local certificate_name="INNORIX"
  local cert_db cert_dir

  while IFS= read -r cert_db; do
    cert_dir="$(dirname "${cert_db}")"
    "${INSTALL_DIR}/certutil" -A -n "${certificate_name}" -t "TC,Cw,Tw" -i "${certificate_file}" -d "sql:${cert_dir}" || true
    "${INSTALL_DIR}/certutil" -A -n "${certificate_name}" -t "TC,Cw,Tw" -i "${certificate_file}" -d "${cert_dir}" || true
  done < <(find "${HOME}"/.mozilla* -name "cert8.db" 2>/dev/null)

  while IFS= read -r cert_db; do
    cert_dir="$(dirname "${cert_db}")"
    "${INSTALL_DIR}/certutil" -A -n "${certificate_name}" -t "TC,Cw,Tw" -i "${certificate_file}" -d "sql:${cert_dir}" || true
  done < <(find "${HOME}"/.mozilla* "${HOME}"/snap/firefox/common/.mozilla/firefox* "${HOME}"/.pki/nssdb -name "cert9.db" 2>/dev/null)

  while IFS= read -r cert_db; do
    cert_dir="$(dirname "${cert_db}")"
    "${INSTALL_DIR}/certutil" -A -n "${certificate_name}" -t "TC,Cw,Tw" -i "${certificate_file}" -d "sql:${cert_dir}" || true
  done < <(find "${HOME}"/.thunderbird -name "cert8.db" 2>/dev/null)
}

start_agent() {
  rewrite_configs
  import_certificates

  if pgrep -f 'innorixas.bin' >/dev/null; then
    exit 0
  fi

  rm -f "${PID_FILE}"
  if ! pgrep -f 'innorixst.bin' >/dev/null; then
    rm -f "${TRAY_FILE}"
  fi

  mkdir -p "${HOME}/.config/autostart"
  cp -f "${HOME}/.local/share/applications/innorix-agent.desktop" "${HOME}/.config/autostart/innorix-agent.desktop"

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

case "${1:-}" in
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
