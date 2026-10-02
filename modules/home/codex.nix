{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  rufloPkg = self.packages.${pkgs.system}.ruflo;
  rufloBin = "${rufloPkg}/bin/claude-flow";
  ouroborosPkg = self.packages.${pkgs.system}.ouroboros;
  ouroborosBin = "${ouroborosPkg}/bin/ouroboros";
  ocxBin = "${self.packages.${pkgs.system}.opencodex}/bin/ocx";
  ouroborosToolBin = "${homeDir}/.local/share/uv/tools/ouroboros-ai/bin/ouroboros";
  ouroborosToolSpec = "ouroboros-ai[mcp]==0.41.0";
  ouroborosMcp = pkgs.writeShellApplication {
    name = "ouroboros-mcp";
    text = ''
      ${lib.optionalString pkgs.stdenv.isLinux ''
        export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      ''}
      exec "${ouroborosToolBin}" "$@"
    '';
  };
  homeDir = config.home.homeDirectory;

  # Written via home.activation (not home.file) as a plain, mutable file —
  # home.file would symlink it into the read-only Nix store, and `ocx sync`/
  # `ocx init` (modules/home/opencodex.nix) need to rewrite this file at
  # runtime to inject their own provider/catalog entries. A rebuild just
  # re-stamps it back to this declared baseline, same convention as the
  # noctalia GUI-vs-Nix settings split.
  codexConfigToml = pkgs.writeText "codex-config.toml" ''
    model = "gpt-6-sol"
    model_reasoning_effort = "medium"

    [projects."${homeDir}"]
    trust_level = "trusted"

    [projects."${homeDir}/ownix"]
    trust_level = "trusted"

    [projects."${homeDir}/ownsidian"]
    trust_level = "trusted"

    [projects."${homeDir}/다운로드/HCI_user& context analysis_Team5"]
    trust_level = "trusted"

    [plugins."github@openai-curated"]
    enabled = true

    [mcp_servers.ruflo]
    command = "${rufloBin}"
    args = ["mcp", "start"]
    startup_timeout_sec = 180

    [mcp_servers.ouroboros]
    command = "${ouroborosMcp}/bin/ouroboros-mcp"
    args = ["mcp", "serve", "--runtime", "codex", "--llm-backend", "codex"]
    startup_timeout_sec = 180
  '';
in
{
  home.packages = [
    rufloPkg
    ouroborosPkg
  ];

  home.file.".ouroboros/config.yaml".text = ''
    orchestrator:
      runtime_backend: codex

    llm:
      backend: codex

    clarification:
      default_model: gpt-6-sol

    evaluation:
      semantic_model: gpt-6-sol

    consensus:
      advocate_model: gpt-6-sol
      devil_model: gpt-6-sol
      judge_model: gpt-6-sol
  '';

  # Plain file, not a symlink (see codexConfigToml above) — `install` copies
  # the content in so the result is writable, then leaves it alone until the
  # next activation re-stamps it.
  home.activation.writeCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -D -m 0644 ${codexConfigToml} "${homeDir}/.codex/config.toml"
  '';

  # writeCodexConfig above just reset config.toml to the declared baseline,
  # which wipes opencodex's own openai_base_url/catalog injections — without
  # this, every `fr` silently un-points Codex's native routing back at OpenAI
  # directly (routing=native, proxy unused) until someone remembers to run
  # `ocx sync` by hand. Re-inject it here so the proxy routing survives a
  # rebuild unattended. Non-fatal: opencodex may not be built/installed yet on
  # a fresh machine, or the proxy may be down mid-switch.
  home.activation.resyncOpencodex = lib.hm.dag.entryAfter [ "writeCodexConfig" ] ''
    ${ocxBin} sync \
      || warnEcho "opencodex: ocx sync failed; Codex routing may still point at OpenAI natively (run 'ocx sync' by hand)"
  '';

  # Both steps need the network (PyPI). During a `nixos-rebuild switch` the
  # activation can race NetworkManager/systemd-resolved being restarted, so a
  # transient DNS failure here must not fail the whole switch.
  home.activation.refreshOuroborosCodex = lib.hm.dag.entryAfter [ "writeCodexConfig" ] ''
    if ! ${pkgs.uv}/bin/uv tool install \
      --quiet \
      --force \
      --no-python-downloads \
      --python ${pkgs.python312}/bin/python3 \
      '${ouroborosToolSpec}'; then
      warnEcho "ouroboros: uv tool install failed (network?); keeping the existing install"
    fi

    ${ouroborosMcp}/bin/ouroboros-mcp codex refresh \
      || warnEcho "ouroboros: codex refresh failed; skipping"
  '';
}
