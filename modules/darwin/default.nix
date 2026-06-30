{
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
