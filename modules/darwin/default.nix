{
  config,
  lib,
  pkgs,
  inputs,
  self,
  username,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) gitUsername;
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  kittyTerminfoAlias = pkgs.runCommand "kitty-terminfo-alias" { } ''
    xterm_kitty="$(find "${pkgs.kitty.terminfo}/share/terminfo" -type f -name xterm-kitty | head -n 1)"
    test -n "$xterm_kitty"
    mkdir -p "$out/share/terminfo/6b" "$out/share/terminfo/k"
    cp "$xterm_kitty" "$out/share/terminfo/6b/kitty"
    ln -s "$out/share/terminfo/6b/kitty" "$out/share/terminfo/k/kitty"
  '';
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    brave
    discord
    git
    google-chrome
    kitty
    kitty.terminfo
    kittyTerminfoAlias
    nh
    unstable.codex
    vim
    vscode
    zotero
  ];

  fonts.packages = with pkgs; [
    cascadia-code
    fira-code
    font-awesome
    inter
    jetbrains-mono
    maple-mono.NF
    nerd-fonts.caskaydia-cove
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  environment.variables.TERMINFO_DIRS = [
    "${kittyTerminfoAlias}/share/terminfo"
    "${pkgs.kitty.terminfo}/share/terminfo"
    "$HOME/.nix-profile/share/terminfo"
    "/etc/profiles/per-user/${username}/share/terminfo"
    "/run/current-system/sw/share/terminfo"
    "/nix/var/nix/profiles/default/share/terminfo"
    "/usr/share/terminfo"
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
  };

  programs.zsh.enable = true;

  services.tailscale.enable = true;

  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2
    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"

    find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while read -r app_link; do
      app_target="$(readlink "$app_link")"
      app_name="$(basename "$app_target")"
      ${pkgs.mkalias}/bin/mkalias "$app_target" "/Applications/Nix Apps/$app_name"
      rm -rf "/Applications/$app_name"
      ${pkgs.mkalias}/bin/mkalias "$app_target" "/Applications/$app_name"
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f "$app_target" \
        -f "/Applications/Nix Apps/$app_name" \
        -f "/Applications/$app_name"
    done
  '';

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    description = gitUsername;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit
        inputs
        self
        username
        host
        ;
      profile = "darwin";
    };
    users.${username} = {
      imports = [
        ../home/darwin.nix
      ];
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "23.11";
      };
    };
  };

  system.stateVersion = 5;
}
