{ config, lib, pkgs, ... }:

{
  # 1. 기존 SSH 설정 (선언적으로 관리됨)
  programs.ssh = {
    enable = true;
    
    # 여기에 본인이 쓰던 설정 그대로 유지
    extraConfig = ''
      Host hanbat_a100
        HostName 210.110.250.120
        User user
        Port 16022
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

      Host 10.0.2.*
        User work
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        # NixOS니까 nc 경로를 명확히 찾기 위해 경로 없이 쓰거나, 아래 2단계 확인 필수
        ProxyCommand nc -X 5 -x 127.0.0.1:1080 %h %p

          '';
  };

  # 2. [핵심] Activation Script: 설정 적용 후 권한 수정 자동화
  # Nix가 만든 심볼릭 링크를 실제 파일로 변환하고 권한을 600으로 변경합니다.
  # home.activation.fixSshConfigPermission = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   # ~/.ssh/config 파일 경로 정의
  #   SSH_CONFIG="$HOME/.ssh/config"
  #
  #   # 만약 ~/.ssh/config가 심볼릭 링크라면 (Nix가 생성한 것이라면)
  #   if [ -L "$SSH_CONFIG" ]; then
  #     # 링크가 가리키는 원본(Nix Store) 경로를 가져옴
  #     TARGET_PATH=$(readlink "$SSH_CONFIG")
  #
  #     # 1. 심볼릭 링크 삭제
  #     $DRY_RUN_CMD rm "$SSH_CONFIG"
  #
  #     # 2. 원본 내용을 복사해서 '실제 파일'로 생성 (이제 수정 가능해짐)
  #     $DRY_RUN_CMD cp "$TARGET_PATH" "$SSH_CONFIG"
  #
  #     # 3. 권한을 600 (나만 읽기/쓰기)으로 강제 변경
  #     $DRY_RUN_CMD chmod 600 "$SSH_CONFIG"
  #
  #     # (선택사항) 로그 출력
  #     if [ -z "$DRY_RUN_CMD" ]; then
  #       echo "Fixed permissions for $SSH_CONFIG (converted symlink to file with 600)"
  #     fi
  #   fi
  # '';
}
