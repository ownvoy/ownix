# modules/core/paseo-tunnel.nix
# SSH 터널 — 원격 Paseo 데몬(bai-vscode, H100_proxy)을
# 로컬 포트로 포워딩해서 데스크탑 앱에서 연결할 수 있게 함.
#
# 사용법:
#   데스크탑 앱 Settings → Direct connection
#     Host: localhost
#     Port: 6768 (bai-vscode) 또는 6769 (H100_proxy)
#
{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────
  # bai-vscode 터널 → localhost:6768
  # ──────────────────────────────────────────────
  systemd.services."tunnel-bai-vscode" = {
    description = "SSH tunnel to bai-vscode Paseo daemon (localhost:6768)";
    after = [ "network.target" "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      exec ${pkgs.openssh}/bin/ssh \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -o StrictHostKeyChecking=accept-new \
        -N -L 6768:localhost:6767 bai-vscode
    '';
  };

  # ──────────────────────────────────────────────
  # H100_proxy 터널 → localhost:6769
  # (ProxyJump A6000 → H100_proxy)
  # ──────────────────────────────────────────────
  systemd.services."tunnel-h100-proxy" = {
    description = "SSH tunnel to H100_proxy Paseo daemon (localhost:6769)";
    after = [ "network.target" "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
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
    after = [ "network.target" "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      exec ${pkgs.openssh}/bin/ssh \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
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
    PASEO_TUNNEL_BAI_VSCODE = "localhost:6768";
    PASEO_TUNNEL_H100_PROXY = "localhost:6769";
    PASEO_TUNNEL_HANBAT_A100 = "localhost:6770";
  };
}
