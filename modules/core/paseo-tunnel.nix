# modules/core/paseo-tunnel.nix
# SSH 터널 — 원격 Paseo 데몬(H100_proxy)을
# 로컬 포트로 포워딩해서 데스크탑 앱에서 연결할 수 있게 함.
#
# 사용법:
#   데스크탑 앱 Settings → Direct connection
#     Host: localhost
#     Port: 6769 (H100_proxy)
#
{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────
  # H100_proxy 터널 → localhost:6769
  # (ProxyJump A6000 → H100_proxy)
  # ──────────────────────────────────────────────
  systemd.services."tunnel-h100-proxy" = {
    description = "SSH tunnel to H100_proxy Paseo daemon (localhost:6769)";
    after = [ "network-online.target" "NetworkManager-wait-online.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
      RestartMode = "direct";
      RestartSec = 10;
    };
    script = ''
      exec ${pkgs.openssh}/bin/ssh \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -o StrictHostKeyChecking=accept-new \
        -N -L 6769:localhost:6767 H100_proxy
    '';
  };

  # ──────────────────────────────────────────────
  # hanbat_a100 터널 → localhost:6770
  # ──────────────────────────────────────────────
  systemd.services."tunnel-hanbat-a100" = {
    description = "SSH tunnel to hanbat_a100 Paseo daemon (localhost:6770)";
    after = [ "network-online.target" "NetworkManager-wait-online.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
      RestartMode = "direct";
      RestartSec = 10;
    };
    script = ''
      exec ${pkgs.openssh}/bin/ssh \
        -o ForwardX11=no \
        -o ForwardX11Trusted=no \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=6 \
        -o TCPKeepAlive=yes \
        -o ExitOnForwardFailure=yes \
        -o StrictHostKeyChecking=accept-new \
        -N -L 6770:localhost:6767 hanbat_a100
    '';
  };

  # ──────────────────────────────────────────────
  # 데스크탑 앱에서 쉽게 전환할 수 있도록
  # 환경변수로 터널 정보 노출
  # ──────────────────────────────────────────────
  environment.sessionVariables = {
    PASEO_TUNNEL_H100_PROXY = "localhost:6769";
    PASEO_TUNNEL_HANBAT_A100 = "localhost:6770";
  };
}
