{ config, lib, pkgs, ... }:

{
  # 1. 기존 SSH 설정 (선언적으로 관리됨)
  programs.ssh = {
    enable = true;
    
    # 여기에 본인이 쓰던 설정 그대로 유지
    extraConfig = ''
      Host 192.168.0.83 Wonjuns-MacBook-Air macbook-air
        HostName 192.168.0.83
        User wonjun
        SetEnv TERM=xterm-256color

      Host hanbat_a100
        HostName 210.110.250.120
        User user
        Port 16022
        IdentityFile ~/.ssh/id_ed25519
        ForwardX11 yes
        ForwardX11Trusted yes

      Host seoultech_h100
        HostName 117.17.185.235
        User seoultech
        Port 22

      Host seoultech_a6000
        HostName 117.17.185.27
        User user
        Port 22

      Host A6000
        HostName 117.17.185.27
        User user
        Port 25565
      
      Host H100_proxy
        HostName 117.17.185.235
        User seoultech
        ProxyJump A6000

      # New H200 Configurations
      Host H200_up_up
        HostName 13.124.117.51
        User ec2-user
        IdentityFile ~/.ssh/kaist.pem

      Host H200_main
        HostName wbl-kaist-gpu-1
        User ubuntu
        ProxyJump H200_up_up
        IdentityFile ~/.ssh/kaist-id-rsa

      Host kaist_GB300
        HostName 143.248.249.13
        User mlp
        Port 22
        IdentityFile ~/.ssh/id_ed25519

      Host 10.0.2.*
        User work
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        # NixOS니까 nc 경로를 명확히 찾기 위해 경로 없이 쓰거나, 아래 2단계 확인 필수
        ProxyCommand nc -X 5 -x 127.0.0.1:1080 %h %p

      Host vml 100.73.57.38
        HostName 100.73.57.38
        User vml
        IdentityFile ~/.ssh/id_ed25519

      Host my-desktop 100.127.76.68
        HostName 100.127.76.68
        User ownvoy
        IdentityFile ~/.ssh/id_ed25519

          '';
  };

  # ── SSH 에이전트 (systemd user service) ──
  # Paseo 에이전트가 SSH 접속(hanbat_a100, H100_proxy 등)할 때
  # SSH_AUTH_SOCK = /run/user/$UID/ssh-agent 를 통해 키 사용
  services.ssh-agent = {
    enable = true;
  };

  # 2a. [선행 정리] link 단계 전에 이전 activation이 남긴 실제 파일/백업을 제거.
  # fixSshConfigPermission이 심볼릭 링크를 실제 파일로 바꿔 두기 때문에, 다음 rebuild 때
  # home-manager의 checkLinkTargets가 "방해되는 파일"로 인식해 config.hm-backup으로
  # 백업하려다, 이전 백업이 남아 있으면 activation이 실패한다. 링크 전에 청소해서 이 루프를 끊는다.
  home.activation.cleanSshConfigBeforeLink = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    SSH_CONFIG="$HOME/.ssh/config"

    # 우리가 실제 파일로 변환해 둔 config를 제거해 home-manager가 깨끗하게 재링크하도록 함.
    # (내용은 선언적으로 관리되므로 손실 없음)
    if [ -e "$SSH_CONFIG" ] && [ ! -L "$SSH_CONFIG" ]; then
      $DRY_RUN_CMD rm -f "$SSH_CONFIG"
    fi

    # activation을 막을 수 있는 오래된 백업 제거.
    $DRY_RUN_CMD rm -f "$SSH_CONFIG.hm-backup"
  '';

  # 2b. [핵심] Activation Script: 설정 적용 후 권한 수정 자동화
  # Nix가 만든 심볼릭 링크를 실제 파일로 변환하고 권한을 600으로 변경합니다.
  home.activation.fixSshConfigPermission = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SSH_CONFIG="$HOME/.ssh/config"

    if [ -L "$SSH_CONFIG" ]; then
      TARGET_PATH=$(readlink "$SSH_CONFIG")

      $DRY_RUN_CMD rm "$SSH_CONFIG"
      $DRY_RUN_CMD cp "$TARGET_PATH" "$SSH_CONFIG"
      $DRY_RUN_CMD chmod 600 "$SSH_CONFIG"

      if [ -z "$DRY_RUN_CMD" ]; then
        echo "Fixed permissions for $SSH_CONFIG (converted symlink to file with 600)"
      fi
    fi
  '';
}
