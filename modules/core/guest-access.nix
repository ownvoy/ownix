# modules/core/guest-access.nix
#
# 외부인(테일스케일 미설치, A6000 계정 없음)에게 이 데스크탑의 게스트 쉘을 주고,
# 거기서 `ssh H100_proxy` 로 A6000 → H100 에 들어가게 한다.
#
#   상대 → [Tailscale Funnel: my-desktop.taild9637e.ts.net:10000] → 이 데스크탑(guest)
#        → ssh H100_proxy → A6000(117.17.185.27:25565) → H100(117.17.185.235)
#
# 이 데스크탑은 NAT(192.168.0.229) 뒤라 인바운드가 안 되므로, Funnel 이 유일한 진입로다.
#
# 켜져 있는 동안 sshd 가 공개 인터넷에 노출되므로 기본은 꺼둔다.
# 필요할 때만 hosts/<host>/variables.nix 의 guestAccessEnable = true 로 켜고,
# 끝나면 다시 끈다. 설치 순서는 파일 하단 "1회 수동 작업" 주석 참고.
#
{ host, pkgs, lib, ... }:

let
  guestAccessEnable =
    (import ../../hosts/${host}/variables.nix).guestAccessEnable or false;

  # ── 상대가 이 데스크탑에 로그인할 때 쓸 공개키 ──
  guestKeys = [
    # "ssh-ed25519 AAAA...상대공개키... 상대이름@노트북"
  ];

  funnelPort = 10000; # Funnel TCP 는 443 / 8443 / 10000 만 지원
in
{
  config = lib.mkIf guestAccessEnable {
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
    # 2. sshd — 공개 인터넷에 노출되는 동안의 추가 잠금
    # ──────────────────────────────────────────────
    # 비밀번호/키보드 인터랙티브 로그인은 services.nix 에서 이미 전역으로 꺼져
    # 있다(키 전용). 여기서는 노출 중일 때만 인증 시도 횟수를 더 줄인다.
    services.openssh.settings.MaxAuthTries = 3;

    # 주의: 이 기본 모드는 guest 에게 데스크탑 쉘을 준다. 같은 머신의 사용자는
    # 127.0.0.1 에만 열린 서비스에도 닿는데, 2026-10 기준 인증 없이 열린 것들이
    # 있다 — Paseo 데몬(6767, ownvoy 권한으로 에이전트 실행), 원격 Paseo 터널
    # (6769/6770), opencodex(10100). 실제로 열어줄 땐 아래 강화 모드를 쓸 것.
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
  };

  # ══════════════════════════════════════════════
  # 1회 수동 작업 (rebuild 전후)
  # ══════════════════════════════════════════════
  #
  # (a) [rebuild 전] hosts/my-desktop/variables.nix 의 guestAccessEnable = true,
  #     상대 공개키를 위 guestKeys 에 추가.
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
  #           guestKeys 비우고 guestAccessEnable = false 로 rebuild.
  #           `--bg` 로 켠 Funnel 설정은 tailscaled 에 저장돼 남을 수 있으니
  #           `tailscale funnel status` 로 확인하고, 남아 있으면 `sudo tailscale funnel reset`.
}
