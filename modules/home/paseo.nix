# modules/home/paseo.nix
# Home-manager module for Paseo user environment.
#
# Installs the desktop app for the user and provides a place
# to configure agent CLIs that Paseo spawns.
#
# SSH 설정은 ssh.nix 에서 관리 (services.ssh-agent.enable 로
# ssh-agent 실행, SSH config 선언).
#
{ config, pkgs, inputs, ... }:

let
  # Patched so the context-window tooltip shows Codex quota for our
  # opencodex-native GPT models proxied through the "claude" provider — see
  # modules/core/paseo.nix (paseoUsageProviderOverridePatch) for the full
  # rationale and the same override applied to services.paseo.package.
  # This home-manager profile is what actually lands on PATH as
  # `paseo-desktop` (/etc/profiles/per-user/<user>/bin takes precedence over
  # /run/current-system/sw/bin), so it must carry the same patch or the
  # desktop app silently reverts to the unpatched build on every launch.
  paseoPkgs = inputs.paseo.packages.${pkgs.system} // {
    desktop = (inputs.paseo.packages.${pkgs.system}.desktop).overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../../patches/paseo-claude-usage-shows-codex-quota.patch ];
    });
  };
in
{
  # ──────────────────────────────────────────────
  # Desktop app in the user profile
  # ──────────────────────────────────────────────
  home.packages = [
    paseoPkgs.desktop
  ];

  # ──────────────────────────────────────────────
  # Agent CLIs — Paseo가 실행할 에이전트들.
  # PATH에 있어야 하므로 여기에 설치.
  # ──────────────────────────────────────────────
  # Claude Code (via claude-code-nix overlay)
  # nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
  # home.packages = [ pkgs.claude-code ];

  # Codex
  # home.packages = [ pkgs.nodePackages."@openai/codex" ];

  # OpenCode
  # home.packages = [ pkgs.opencode ];
}
