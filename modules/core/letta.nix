# modules/core/letta.nix
# Letta — self-hosted stateful agent runtime (persistent memory).
# https://docs.letta.com
#
# Provides:
#   - letta CLI          : interactive/headless Letta agent runner
#   - services.letta     : Letta App Server on ws://127.0.0.1:4500 (--openai-api)
#
# Agent state lives in ~/.letta/lc-local-backend (user ownvoy).
# After first boot, connect an LLM provider once:
#   letta --backend local connect anthropic   # or openai / ollama / lmstudio ...
#   letta --backend local --new-agent
#
# opencode integration: a custom provider points at
#   http://127.0.0.1:4500/v1  (@ai-sdk/openai-compatible)
# and lists the Letta agent id under provider.letta.models
# (see ~/.config/opencode/opencode.jsonc).
#   curl http://127.0.0.1:4500/v1/models   # shows each Letta agent as a model
#
# NOTE: npm install of @letta-ai/letta-code compiles native deps, so the
# service PATH includes python3/gcc/make/pkg-config.
#
{ config, pkgs, lib, ... }:

let
  lettaVersion = "0.30.6";

  # Letta CLI — npx wrapper (same pattern as the `ruflo`/`ouroboros` packages).
  letta = pkgs.writeShellApplication {
    name = "letta";
    runtimeInputs = [
      pkgs.nodejs
      pkgs.python3
      pkgs.gcc
      pkgs.gnumake
      pkgs.pkg-config
    ];
    text = ''
      export npm_config_cache="''${XDG_CACHE_HOME:-$HOME/.cache}/letta-npm"
      export npm_config_fund=false
      export npm_config_update_notifier=false

      exec npx --yes @letta-ai/letta-code@${lettaVersion} "$@"
    '';
  };
in
{
  environment.systemPackages = [ letta ];

  # ──────────────────────────────────────────────
  # App Server — runs the stateful agent runtime,
  # listening on loopback ws://127.0.0.1:4500.
  # ──────────────────────────────────────────────
  systemd.services.letta = {
    description = "Letta App Server (stateful agent runtime)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ownvoy";
      Restart = "on-failure";
      RestartSec = 10;
    };
    environment = {
      # npm runs lifecycle scripts (e.g. @google/genai postinstall) that need
      # `sh`/bash + coreutils + a C toolchain. mkForce because systemd.nix
      # also defines environment.PATH by default.
      PATH = lib.mkForce (lib.makeBinPath [
        pkgs.nodejs
        pkgs.python3
        pkgs.gcc
        pkgs.gnumake
        pkgs.pkg-config
        pkgs.binutils
        pkgs.bash
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
        pkgs.findutils
        pkgs.gawk
        pkgs.which
      ]);
    };
    script = ''
      export npm_config_cache="/home/ownvoy/.cache/letta-npm"
      export npm_config_fund=false
      export npm_config_update_notifier=false

      exec ${pkgs.nodejs}/bin/npx --yes @letta-ai/letta-code@${lettaVersion} \
        server \
        --backend local \
        --listen ws://127.0.0.1:4500 \
        --openai-api
    '';
  };
}
