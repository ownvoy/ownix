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
  paseoPkgs = inputs.paseo.packages.${pkgs.system};
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
