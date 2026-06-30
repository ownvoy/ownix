{
  host,
  username,
  pkgs,
  ...
}:
let
  appCommand = name: appName:
    pkgs.writeShellScriptBin name ''
      exec /usr/bin/open -a '${appName}' "$@"
    '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "fr" ''
      exec sudo darwin-rebuild switch --flake path:/Users/${username}/ownix#${host} "$@"
    '')
    (pkgs.writeShellScriptBin "fu" ''
      cd /Users/${username}/ownix
      nix flake update
      exec sudo darwin-rebuild switch --flake path:/Users/${username}/ownix#${host} "$@"
    '')
    (appCommand "brave" "Brave Browser")
    (appCommand "chrome" "Google Chrome")
    (appCommand "discord" "Discord")
    (appCommand "zotero" "Zotero")
  ];
}
