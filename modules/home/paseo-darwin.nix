# modules/home/paseo-darwin.nix
# macOS side of the Paseo setup (mirrors modules/core/paseo-tunnel.nix on
# my-desktop, using launchd agents instead of systemd units).
#
# The Paseo.app cask (modules/darwin/homebrew.nix) is only the desktop GUI —
# it has no daemon of its own on this machine. These agents open background
# SSH tunnels to the three existing remote daemons and forward each one to
# a local port, so the app can add them as Direct Connections:
#
#   bai-vscode -> localhost:6768
#   H100_proxy -> localhost:6769
#   my-desktop -> localhost:6770
#
# All three SSH aliases are already declared in modules/home/ssh.nix.
{ config, lib, ... }:
let
  mkTunnel = { name, remotePort ? 6767, localPort, host }: {
    "paseo-tunnel-${name}" = {
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
        StandardOutPath = "/tmp/paseo-tunnel-${name}.stdout.log";
        StandardErrorPath = "/tmp/paseo-tunnel-${name}.stderr.log";
      };
    };
  };
in
{
  launchd.agents = lib.mkMerge [
    (mkTunnel { name = "bai-vscode"; localPort = 6768; host = "bai-vscode"; })
    (mkTunnel { name = "h100-proxy"; localPort = 6769; host = "H100_proxy"; })
    (mkTunnel { name = "my-desktop"; localPort = 6770; host = "my-desktop"; })
  ];
}
