# modules/core/guest-access.nix
#
# 외부인(테일스케일 미설치, A6000 계정 없음)에게 이 데스크탑의 게스트 쉘을 주고,
# 거기서 `ssh H100_proxy` 로 A6000 → H100 에 들어가게 한다.
#
#   상대 → [Tailscale Funnel: my-desktop.taild9637e.ts.net:10000] → 이 데스크탑(guest)
#        → ssh H100_proxy → A6000(117.17.185.27:25565) → H100(117.17.185.235)
#
# 이 데스크탑은 NAT(192.168.0.229) 뒤라 인바운드가 안 되므로, Funnel 이 유일한 진입로다.
# 설치 순서는 파일 하단 "1회 수동 작업" 주석 참고.
#
{ pkgs, lib, ... }:

let
  # ── 상대가 이 데스크탑에 로그인할 때 쓸 공개키 ──
  guestKeys = [
    # "ssh-ed25519 AAAA...상대공개키... 상대이름@노트북"
  ];

  funnelPort = 10000; # Funnel TCP 는 443 / 8443 / 10000 만 지원
in
{
  # ──────────────────────────────────────────────
  # 1. 게스트 계정 (공개키 전용, 특권 그룹 없음)
  # ──────────────────────────────────────────────
  users.users.guest = {
    isNormalUser = true;
    description = "External guest (shell -> H100_proxy)";
    hashedPassword = "!"; # 비밀번호 로그인 불가
    shell = pkgs.bashInteractive;
    extraGroups = [ ]; # wheel/docker/libvirtd 등 일절 없음
    openssh.authorizedKeys.keys = guestKeys;
  };

  # guest 는 nix 데몬 사용 불가 (user.nix 의 allowed-users 와 리스트 병합됨)

  # ──────────────────────────────────────────────
  # 2. sshd — 공개 인터넷에 노출되므로 키 전용으로 잠근다
  # ──────────────────────────────────────────────
  # services.nix 는 PasswordAuthentication = true 지만, Funnel 로 sshd 가
  # 공개되는 이상 비밀번호 브루트포스 표면을 남겨둘 수 없다.
  # ownvoy 는 ~/.ssh/authorized_keys 에 키 3개가 등록돼 있어 잠기지 않는다.
  services.openssh.settings.PasswordAuthentication = lib.mkForce false;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce false;
  services.openssh.settings.MaxAuthTries = 3;

  services.openssh.extraConfig = ''
    Match User guest
      X11Forwarding no
      AllowAgentForwarding no
      PermitTunnel no
      AllowTcpForwarding yes
    Match all
  '';

  # ── (선택) 강화 모드 ────────────────────────────────────────
  # 위 블록을 아래로 갈아끼우면 guest 는 데스크탑 쉘을 아예 못 받고
  # 접속 즉시 H100 으로 떨어진다. /home/guest/.ssh/id_ed25519 를
  # 상대가 빼갈 수 없게 되는 게 핵심 이득. 대신 scp/포트포워딩은 막힌다.
  #
  #   Match User guest
  #     X11Forwarding no
  #     AllowAgentForwarding no
  #     AllowTcpForwarding no
  #     PermitTunnel no
  #     PermitTTY yes
  #     ForceCommand /run/current-system/sw/bin/ssh -t H100_proxy
  #   Match all

  # ──────────────────────────────────────────────
  # 3. 시스템 전역 ssh 클라이언트 설정
  #    guest 홈에 ~/.ssh/config 를 안 만들어도 `ssh H100_proxy` 가 동작.
  #    (ownvoy 는 home-manager 가 만든 ~/.ssh/config 가 우선하므로 영향 없음)
  # ──────────────────────────────────────────────
  programs.ssh.extraConfig = ''
    Host A6000
      HostName 117.17.185.27
      User user
      Port 25565
      IdentityFile ~/.ssh/id_ed25519
      StrictHostKeyChecking accept-new

    Host H100_proxy
      HostName 117.17.185.235
      User seoultech
      IdentityFile ~/.ssh/id_ed25519
      ProxyJump A6000
      StrictHostKeyChecking accept-new
  '';

  # ──────────────────────────────────────────────
  # 4. Tailscale Funnel — sshd 를 공개 TCP 로 노출
  #    my-desktop.taild9637e.ts.net:10000 → localhost:22
  # ──────────────────────────────────────────────
  systemd.services.tailscale-funnel-ssh = {
    description = "Expose sshd on the public internet via Tailscale Funnel (tcp/${toString funnelPort})";
    after = [ "tailscaled.service" "sshd.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 15;
      ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg --yes --tcp ${toString funnelPort} tcp://localhost:22";
      ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --tcp ${toString funnelPort} off";
    };
  };

  # ══════════════════════════════════════════════
  # 1회 수동 작업 (rebuild 전후)
  # ══════════════════════════════════════════════
  #
  # (a) [rebuild 전] 상대 공개키를 위 guestKeys 에 추가.
  #     상대가 자기 컴에서:  ssh-keygen -t ed25519 -C "이름@노트북"
  #                          cat ~/.ssh/id_ed25519.pub
  #
  # (b) [admin 콘솔] Tailscale Funnel 활성화 — 최초 1회만.
  #     https://login.tailscale.com/admin/dns    → HTTPS Certificates 켜기
  #     https://login.tailscale.com/admin/acls   → nodeAttrs 에 "funnel" 추가
  #     (아래 c 를 수동 실행하면 활성화 링크를 직접 뱉어준다)
  #
  # (c) sudo nixos-rebuild switch --flake .#my-desktop
  #     systemctl status tailscale-funnel-ssh
  #     tailscale funnel status        # 10000 → localhost:22 로 떠야 함
  #
  # (d) 게스트 전용 상위홉 키 생성 — 내 id_ed25519 는 절대 복사하지 말 것.
  #     sudo -u guest install -d -m700 /home/guest/.ssh
  #     sudo -u guest ssh-keygen -t ed25519 -N '' \
  #          -f /home/guest/.ssh/id_ed25519 -C 'guest@my-desktop'
  #
  # (e) 그 공개키를 A6000 과 H100 양쪽 authorized_keys 에 등록 (ownvoy 로 실행)
  #     GK="$(sudo cat /home/guest/.ssh/id_ed25519.pub)"
  #     ssh A6000      "install -d -m700 ~/.ssh && echo \"$GK\" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  #     ssh H100_proxy "install -d -m700 ~/.ssh && echo \"$GK\" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  #
  # (f) 회수: 두 서버 authorized_keys 에서 그 한 줄 삭제 +
  #           위 guestKeys 비우고 rebuild + `tailscale funnel reset`
}
