# modules/home/claude-code.nix
# Declarative Claude Code CLI via github:sadjow/claude-code-nix.
# home-manager runs with useGlobalPkgs = false, so applying the overlay here
# affects this user's pkgs instance (same approach as the other home modules).
{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  home.packages = [ pkgs.claude-code ];
}
