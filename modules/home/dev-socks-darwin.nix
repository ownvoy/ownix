# modules/home/dev-socks-darwin.nix
# Always-on SOCKS tunnel to my-desktop, plus a Chrome profile that uses it.
#
# Dev servers on my-desktop bind 127.0.0.1 and pick a different port every
# time (4000, 5173, 8000, …), so a fixed set of `-L` forwards (the approach in
# paseo-darwin.nix) doesn't fit. A single dynamic forward covers every port at
# once: SOCKS5 hands the hostname to the remote end, so `localhost:<port>` typed
# in the proxied browser resolves on my-desktop, not here.
#
#   launchd agent  : ssh -N -D 127.0.0.1:1080 my-desktop   (KeepAlive)
#   `desk-chrome`  : Chrome with its own profile + that proxy
#   Desk Chrome.app: the same thing as a Dock-able app in ~/Applications
#
# Normal Chrome is untouched — only the separate profile carries the proxy
# flags, so day-to-day browsing never goes through my-desktop.
#
# The SSH alias `my-desktop` is declared in modules/home/ssh.nix.
{ config, pkgs, ... }:
let
  socksPort = 1080;
  remoteHost = "my-desktop";

  chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
  profileDir = "${config.home.homeDirectory}/.local/share/chrome-desk";

  # `<-loopback>` cancels Chrome's implicit "never proxy localhost" rule. Without
  # it Chrome answers localhost from THIS machine and the tunnel is bypassed —
  # which is the whole point of the profile.
  chromeArgs = [
    "--user-data-dir=${profileDir}"
    "--proxy-server=socks5://127.0.0.1:${toString socksPort}"
    "--proxy-bypass-list=<-loopback>"
  ];

  desk-chrome = pkgs.writeShellScriptBin "desk-chrome" ''
    exec "${chromeBin}" ${pkgs.lib.escapeShellArgs chromeArgs} "$@"
  '';
in
{
  home.packages = [ desk-chrome ];

  # ──────────────────────────────────────────────
  # The tunnel itself
  # ──────────────────────────────────────────────
  launchd.agents.dev-socks = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/ssh"
        "-N"
        "-o"
        "ServerAliveInterval=30"
        "-o"
        "ServerAliveCountMax=3"
        "-o"
        "ExitOnForwardFailure=yes"
        "-o"
        "StrictHostKeyChecking=accept-new"
        "-D"
        "127.0.0.1:${toString socksPort}"
        remoteHost
      ];
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/dev-socks.stdout.log";
      StandardErrorPath = "/tmp/dev-socks.stderr.log";
    };
  };

  # ──────────────────────────────────────────────
  # Dock-able wrapper so it doesn't need a terminal
  # ──────────────────────────────────────────────
  home.file."Applications/Desk Chrome.app/Contents/Info.plist".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key>
      <string>Desk Chrome</string>
      <key>CFBundleDisplayName</key>
      <string>Desk Chrome</string>
      <key>CFBundleIdentifier</key>
      <string>local.ownix.desk-chrome</string>
      <key>CFBundleVersion</key>
      <string>1</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleExecutable</key>
      <string>desk-chrome</string>
      <key>LSMinimumSystemVersion</key>
      <string>12.0</string>
    </dict>
    </plist>
  '';

  home.file."Applications/Desk Chrome.app/Contents/MacOS/desk-chrome" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec "${desk-chrome}/bin/desk-chrome" "$@"
    '';
  };
}
