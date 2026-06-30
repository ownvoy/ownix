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
    nh
    vim
    zotero
  ];

  programs.zsh.enable = true;

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
