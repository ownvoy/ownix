{
  config,
  pkgs,
  self,
  ...
}:
let
  rufloPkg = self.packages.${pkgs.system}.ruflo;
  rufloBin = "${rufloPkg}/bin/claude-flow";
  homeDir = config.home.homeDirectory;
in
{
  home.packages = [ rufloPkg ];

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
  '';
}
