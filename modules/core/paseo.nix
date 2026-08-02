# modules/core/paseo.nix
# Paseo — self-hosted daemon + desktop app for AI coding agents.
# https://github.com/getpaseo/paseo
#
# Provides:
#   - services.paseo      : systemd daemon (agent orchestrator)
#   - paseo-desktop       : Electron GUI app (installed system-wide)
#   - SSH agent forwarding: agents spawned by Paseo can SSH into
#     remote servers defined in ssh.nix:
#       hanbat_a100, seoultech_h100, seoultech_a6000, A6000,
#       H100_proxy, H200_up_up, H200_main, bai-vscode, vml, my-desktop
#
{ config, pkgs, inputs, host, ... }:

let
  paseoPkgs = inputs.paseo.packages.${pkgs.system};

  # SSH 에이전트 소켓 경로.
  # home-manager의 services.ssh-agent.enable = true 로 실행된
  # ssh-agent는 /run/user/<UID>/ssh-agent 에 바인딩됩니다.
  # UID를 직접 못 구하면 1000으로 fallback (NixOS 기본값).
  uid = toString (config.users.users.ownvoy.uid or 1000);
  sshAuthSock = "/run/user/${uid}/ssh-agent";
in
{
  imports = [ inputs.paseo.nixosModules.default ];

  # ──────────────────────────────────────────────
  # Desktop app — installs the `paseo-desktop` binary,
  # .desktop file, and hicolor icon.
  # ──────────────────────────────────────────────
  environment.systemPackages = [
    paseoPkgs.desktop
  ];

  # ──────────────────────────────────────────────
  # Daemon service — runs the Paseo server as a
  # systemd unit, accessible at localhost:6767.
  # ──────────────────────────────────────────────
  services.paseo = {
    enable = true;

    # Run as your user so spawned agents see your
    # dev environment (git, ssh, nix, etc.).
    user = "ownvoy";
    inheritUserEnvironment = true;

    # Listening address — keep on loopback unless
    # you need LAN access (then set listenAddress
    # to "0.0.0.0" and openFirewall = true).
    listenAddress = "127.0.0.1";
    port = 6767;

    # ── Remote access via relay ──
    # Default (hosted): connects to app.paseo.sh
    # Set mode = "remote" and provide host/port
    # to use a self-hosted relay.
    relay.enable = true;
    # relay.mode = "remote";
    # relay.host = "relay.example.com";
    # relay.port = 443;

    # ── DNS rebinding protection ──
    # hostnames = [ ".local" "myhost.local" ];

    # ──────────────────────────────────────────────
    # SSH 환경변수 — Paseo 에이전트가 아래 서버들에
    # 접속할 수 있도록 SSH_AUTH_SOCK 전달
    #
    #   hanbat_a100, seoultech_h100, seoultech_a6000,
    #   A6000, H100_proxy, H200_up_up, H200_main,
    #   bai-vscode, vml, my-desktop
    #
    # 원격 데몬 SSH 터널 (paseo-tunnel.nix):
    #   localhost:6768 = bai-vscode daemon
    #   localhost:6769 = H100_proxy daemon
    #   localhost:6770 = hanbat_a100 daemon
    #
    # (SSH config는 home-manager의 ssh.nix에 선언됨)
    # ──────────────────────────────────────────────
    environment = {
      # ssh-agent 소켓 (services.ssh-agent.enable 로 실행됨)
      SSH_AUTH_SOCK = sshAuthSock;

      # GNOME Keyring을 쓴다면 위 경로 대신:
      # SSH_AUTH_SOCK = "/run/user/${uid}/keyring/ssh";
      # (services.ssh-agent 대신 services.gnome-keyring.enable 사용)

      # SSH는 ~/.ssh/config 를 자동으로 읽으므로
      # IdentityFile 경로는 별도 설정 불필요
    };

    # ── Declarative config.json ──
    # WARNING: overrides any runtime mutations
    # (set-password, MCP toggles, etc.) on restart.
    settings = {
      # Example — add agent providers:
      # agents.providers.claude = { extends = "claude-code"; };
      # agents.providers.codex   = { extends = "codex"; };
      # agents.providers.opencode = { extends = "opencode"; };

      # Daemon-level options:
      # daemon.mcp = { enabled = true; injectIntoAgents = false; };
      # log.file   = { level = "info"; path = "/var/lib/paseo/daemon.log"; };
    };
  };

  # ──────────────────────────────────────────────
  # SSH 키 권한 보장 — 600 권한이 없으면 SSH 무시
  # (ssh.nix는 config만 고정하므로 키도 여기서 보장)
  # ──────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "f /home/ownvoy/.ssh/id_ed25519 0600 ownvoy users - -"
    "f /home/ownvoy/.ssh/kaist.pem   0600 ownvoy users - -"
    "f /home/ownvoy/.ssh/kaist-id-rsa 0600 ownvoy users - -"
    "f /home/ownvoy/.ssh/config      0600 ownvoy users - -"
  ];

  # ──────────────────────────────────────────────
  # Electron sandbox workaround
  # ──────────────────────────────────────────────
  # The desktop app passes --no-sandbox, but if you
  # want user-namespace cloning for other Electron
  # apps, enable this:
  # boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
}
