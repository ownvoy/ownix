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
#       H100_proxy, H200_up_up, H200_main, vml, my-desktop
#
{ config, lib, pkgs, inputs, host, self, ... }:

let
  paseoPkgsUnpatched = inputs.paseo.packages.${pkgs.system};

  # Paseo's context-window tooltip shows quota for whatever Paseo `provider`
  # (e.g. "claude") the agent is nominally running under. Our GPT models
  # (agents.providers.claude.additionalModels below) are proxied through
  # `ocx claude` but actually spend Codex/ChatGPT subscription quota, not
  # Anthropic quota — so the tooltip showed nothing useful for them. This
  # patch teaches the tooltip to look up "codex" usage instead, keyed off the
  # `claude-ocx-native--` model-id prefix opencodex uses for its native GPT
  # catalog (modules/home/opencodex.nix). That prefix is our own naming
  # choice, not an upstream convention, so this stays a local patch rather
  # than something to send upstream.
  paseoUsageProviderOverridePatch = ../../patches/paseo-claude-usage-shows-codex-quota.patch;

  applyUsageProviderPatch = drv: drv.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ paseoUsageProviderOverridePatch ];
  });

  paseoPkgs = paseoPkgsUnpatched // {
    paseo = applyUsageProviderPatch paseoPkgsUnpatched.paseo;
    default = applyUsageProviderPatch paseoPkgsUnpatched.default;
    desktop = applyUsageProviderPatch paseoPkgsUnpatched.desktop;
  };

  # SSH 에이전트 소켓 경로.
  # home-manager의 services.ssh-agent.enable = true 로 실행된
  # ssh-agent는 /run/user/<UID>/ssh-agent 에 바인딩됩니다.
  # UID를 선언하지 않으면 users.users.ownvoy.uid 는 속성이 없는 게 아니라
  # null 이라 `or 1000` 이 안 걸린다 (그래서 /run/user//ssh-agent 가 됐었음).
  # null 이면 1000으로 fallback (NixOS 기본값).
  uid = toString (lib.defaultTo 1000 config.users.users.ownvoy.uid);
  sshAuthSock = "/run/user/${uid}/ssh-agent";

  # Paseo's `agents.providers.claude.command` override (ProviderOverrideSchema,
  # a plain argv array) gets converted internally to {mode:"replace", argv}
  # (provider-registry.js toRuntimeSettings), which correctly carries the full
  # argv wherever Paseo compares/executes a command directly (isAvailable,
  # getDiagnostic, resolveClaudeAuth). BUT the actual agent-spawn path
  # (resolveClaudeBinary in providers/claude/agent.js) only keeps
  # `availability.resolvedPath ?? launch.command` — it silently drops
  # `launch.args` — and hands that single path to the Claude Agent SDK as
  # `pathToClaudeCodeExecutable`. So `command = ["ocx" "claude"]` would only
  # ever spawn bare `ocx` (missing the "claude" subcommand `ocx` needs to know
  # to proxy Claude Code at all), while working fine for the shell alias
  # (modules/home/zsh/default.nix) which does pass "claude" through.
  # Workaround: give Paseo a single-token wrapper binary that already bakes in
  # `ocx claude`, so there's no second argv element for Paseo to drop.
  ocxClaudeWrapper = pkgs.writeShellApplication {
    name = "ocx-claude";
    text = ''
      exec "${self.packages.${pkgs.system}.opencodex}/bin/ocx" claude "$@"
    '';
  };
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

    # Patched build — see paseoUsageProviderOverridePatch above (daemon also
    # serves its own web-ui, so it needs the patch independently of desktop).
    package = paseoPkgs.default;

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
    #   vml, my-desktop
    #
    # 원격 데몬 SSH 터널 (paseo-tunnel.nix):
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
      # Route Paseo's built-in "claude" provider through the opencodex proxy
      # (modules/home/opencodex.nix) instead of invoking `claude` directly.
      # Must be a single-token command — see ocxClaudeWrapper above for why
      # `["ocx" "claude"]` doesn't work here (Paseo drops the "claude" arg on
      # the actual spawn path, even though it's honored elsewhere). The
      # wrapper already execs `ocx claude "$@"`, which ensures the proxy is
      # running, injects ANTHROPIC_BASE_URL/model env, and execs the real
      # `claude` binary with stdio inherited (it never writes to stdout
      # itself), so it's a transparent drop-in for whatever args Paseo/the
      # Claude Agent SDK append after it.
      agents.providers.claude = {
        command = [ "${ocxClaudeWrapper}/bin/ocx-claude" ];
        additionalModels = [
          {
            id = "claude-ocx-native--gpt-5.5";
            label = "gpt-5.5 (native)";
          }
          {
            id = "claude-ocx-native--gpt-5.6-sol";
            label = "gpt-5.6-sol (native)";
          }
          {
            id = "claude-ocx-native--gpt-5.6-terra";
            label = "gpt-5.6-terra (native)";
          }
          {
            id = "claude-ocx-native--gpt-5.6-luna";
            label = "gpt-5.6-luna (native)";
          }
          {
            id = "claude-ocx-native--gpt-6-astra";
            label = "gpt-6-astra (native)";
          }
        ];
      };
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
