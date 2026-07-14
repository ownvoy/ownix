# modules/home/pi.nix
# Pi coding agent CLI (github:earendil-works/pi), packaged in nixpkgs as
# `pi-coding-agent`. Like the other AI CLIs here it uses subscriptions, not
# API keys: run `/login` inside pi to authenticate with a Claude Pro/Max,
# ChatGPT Plus/Pro, or GitHub Copilot subscription.
{ pkgs, ... }:

{
  home.packages = [ pkgs.pi-coding-agent ];
}
