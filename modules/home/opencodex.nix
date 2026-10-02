{
  config,
  lib,
  pkgs,
  self,
  ...
}:
# opencodex (`ocx`): a local proxy that lets Claude Code talk to non-Anthropic
# models — here, the ChatGPT/Codex subscription that ~/.codex/auth.json already
# holds — while keeping Claude Code's own UI.
#
# The proxy service is declared here rather than installed with `ocx service`:
# that command writes a unit with hardcoded store paths that nothing restarts on
# rebuild, so the proxy kept running an old bun without Bun.Image and silently
# dropped every pasted image. Pointing ExecStart at the package means any
# opencodex/bun bump changes the unit and home-manager restarts it on switch.
# Do not run `ocx service install/uninstall`; use `systemctl --user` instead.
#
# Everything else is mutable state that `ocx` owns and rewrites
# (~/.opencodex/config.json, the dashboard on http://127.0.0.1:10100), so it is
# deliberately NOT declared here:
#
#   ocx init       # interactive setup, forwards the existing `codex login`
#   ocx claude     # launch Claude Code pointed at the proxy
#
# `ocx claude` exports ANTHROPIC_BASE_URL and gateway model discovery for that
# one process; it never sets ANTHROPIC_API_KEY, so a plain `claude` still uses
# the normal claude.ai subscription login.
let
  opencodex = self.packages.${pkgs.system}.opencodex;

  # Mirrors what `ocx service` generated: export the data-plane token if one has
  # been provisioned, and append output to the log `ocx` itself reads.
  startProxy = pkgs.writeShellScript "opencodex-proxy" ''
    token="$HOME/.opencodex/service-api-token"
    if [ -f "$token" ]; then
      OPENCODEX_API_AUTH_TOKEN="$(cat "$token")"
      export OPENCODEX_API_AUTH_TOKEN
    fi
    exec ${lib.getExe opencodex} start --port 10100 >> "$HOME/.opencodex/service.log" 2>&1
  '';
in
{
  home.packages = [ opencodex ];

  systemd.user.services.opencodex-proxy = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "OpenCodex Proxy Server";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Install.WantedBy = [ "default.target" ];

    Service = {
      Type = "simple";
      ExecStart = "${startProxy}";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "OCX_SERVICE=1"
        "OCX_SERVICE_MANAGED=1"
        # ocx shells out to codex, git, etc.; user services get a bare PATH.
        "PATH=/run/wrappers/bin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
      ];
    };
  };
}
