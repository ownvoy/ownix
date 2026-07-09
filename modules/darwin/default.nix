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
    ./homebrew.nix
    ./tailscale.nix
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        ruby_4_0 = prev.ruby_4_0 or unstable.ruby_4_0;
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    discord
    git
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

  environment.extraInit = lib.mkForce ''
    export NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
    export NIX_PROFILES="/nix/var/nix/profiles/default /run/current-system/sw /etc/profiles/per-user/$USER $HOME/.nix-profile"

    if [ -e "$HOME/.nix-defexpr/channels" ]; then
      export NIX_PATH="$HOME/.nix-defexpr/channels''${NIX_PATH:+:$NIX_PATH}"
    fi
  '';

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

  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2

    cleanup_nix_apps() {
      app_root="$1"
      manifest_dir="$2"

      if [ -d "$manifest_dir" ]; then
        find "$manifest_dir" -maxdepth 1 -mindepth 1 -type f | while read -r marker; do
          old_app="$app_root/$(basename "$marker")"
          if [ -d "$old_app" ]; then
            rm -rf "$old_app"
          fi
        done
        rm -rf "$manifest_dir"
      fi

      if [ -d "$app_root" ]; then
        find "$app_root" -maxdepth 1 -mindepth 1 -type d | while read -r old_app; do
          if [ -f "$old_app/Contents/.ownix-managed-app" ]; then
            rm -rf "$old_app"
          fi
        done
      fi
    }

    applications_manifest="/Applications/.ownix-managed-apps"
    nix_apps_manifest="/Applications/Nix Apps/.ownix-managed-apps"

    cleanup_nix_apps "/Applications" "$applications_manifest"
    cleanup_nix_apps "/Applications/Nix Apps" "$nix_apps_manifest"

    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"
    mkdir -p "$applications_manifest" "$nix_apps_manifest"

    find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while read -r app_link; do
      app_target="$(readlink "$app_link")"
      app_name="$(basename "$app_target")"
      rm -rf "/Applications/Nix Apps/$app_name"
      /usr/bin/ditto "$app_target" "/Applications/Nix Apps/$app_name"
      /usr/bin/xattr -dr com.apple.quarantine "/Applications/Nix Apps/$app_name" 2>/dev/null || true
      touch "$nix_apps_manifest/$app_name"
      rm -rf "/Applications/$app_name"
      /usr/bin/ditto "$app_target" "/Applications/$app_name"
      /usr/bin/xattr -dr com.apple.quarantine "/Applications/$app_name" 2>/dev/null || true
      touch "$applications_manifest/$app_name"
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
