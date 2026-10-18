# modules/home/paseo-darwin.nix
# macOS side of the Paseo setup (mirrors modules/core/paseo-tunnel.nix on
# my-desktop, using launchd agents instead of systemd units).
#
# The Paseo.app cask (modules/darwin/homebrew.nix) is only the desktop GUI —
# it has no daemon of its own on this machine. These agents open background
# SSH tunnels to the existing remote daemons and forward each one to
# a local port, so the app can add them as Direct Connections:
#
#   H100_proxy -> localhost:6769
#   my-desktop -> localhost:6770
#
# Both SSH aliases are already declared in modules/home/ssh.nix.
#
# The same helper also forwards my-desktop's opencodex proxy
# (modules/home/opencodex.nix) to localhost:10100, so the Mac's `claude` alias
# (modules/home/zsh/default.nix) runs Claude Code locally on the Mac's files
# while routing models through my-desktop's ocx. opencodex 403s non-loopback
# Host headers, so it has to stay on the same port behind a loopback forward.
{ config, lib, ... }:
let
  mkTunnel = { name, prefix ? "paseo-tunnel", remotePort ? 6767, localPort, host }: {
    "${prefix}-${name}" = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/ssh"
          "-N"
          "-o" "ServerAliveInterval=30"
          "-o" "ServerAliveCountMax=3"
          "-o" "ExitOnForwardFailure=yes"
          "-o" "StrictHostKeyChecking=accept-new"
          "-L" "${toString localPort}:localhost:${toString remotePort}"
          host
        ];
        EnvironmentVariables = {
          HOME = config.home.homeDirectory;
        };
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/${prefix}-${name}.stdout.log";
        StandardErrorPath = "/tmp/${prefix}-${name}.stderr.log";
      };
    };
  };
in
{
  launchd.agents = lib.mkMerge [
    (mkTunnel { name = "h100-proxy"; localPort = 6769; host = "H100_proxy"; })
    (mkTunnel { name = "my-desktop"; localPort = 6770; host = "my-desktop"; })
    (mkTunnel { name = "my-desktop"; prefix = "ocx-tunnel"; remotePort = 10100; localPort = 10100; host = "my-desktop"; })
  ];
}
