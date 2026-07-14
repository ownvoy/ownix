# modules/core/hermes.nix
# Hermes agent gateway as a NixOS system service.
# The services.hermes-agent module comes from inputs.hermes-agent.nixosModules.default,
# which is imported in flake.nix's mkNixosConfig.
#
# Auth: uses the Codex (ChatGPT) OAuth provider — no API key. After the first
# rebuild, authenticate once as the hermes service user:
#
#   sudo -u hermes env HERMES_HOME=/var/lib/hermes/.hermes \
#     hermes model codex/gpt-5.3-codex
#
# The token is saved to /var/lib/hermes/.hermes/auth.json and persists.
{ ... }: {
  services.hermes-agent = {
    enable = true;
    settings.model.default = "codex/gpt-5.3-codex";
    addToSystemPackages = true;
  };
}
