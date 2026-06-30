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
      default_model: gpt-5.4

    evaluation:
      semantic_model: gpt-5.4

    consensus:
      advocate_model: gpt-5.4
      devil_model: gpt-5.4
      judge_model: gpt-5.4
  '';

  home.file.".codex/config.toml".text = ''
    model = "gpt-5.4"
    model_reasoning_effort = "medium"

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

  home.activation.refreshOuroborosCodex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.uv}/bin/uv tool install \
      --quiet \
      --force \
      --no-python-downloads \
      --python ${pkgs.python312}/bin/python3 \
      '${ouroborosToolSpec}'

    ${ouroborosMcp}/bin/ouroboros-mcp codex refresh
  '';
}
