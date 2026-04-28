{
  description = "Ownix";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    cava-bg.url = "github:leriart/cava-bg";
    # antigravity-nix = {
    #   url = "github:jacopone/antigravity-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Hypersysinfo  (Optional)
    #hyprsysteminfo.url = "github:hyprwm/hyprsysteminfo";

    # QuickShell (optional add quickshell to outputs to enable)
    #quickshell = {
    #  url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixpkgs-unstable,
      agenix,
      # antigravity-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "ownvoy";
      machines = {
        my-desktop = {
          profile = "amd";
        };
        acer-laptop = {
          profile = "intel";
        };
      };

      # Build one NixOS configuration per host.
      mkNixosConfig =
        {
          host,
          profile,
        }:
        nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          inherit host;
          inherit profile;
        };
        modules = [
          ./profiles/${profile}
          nix-flatpak.nixosModules.nix-flatpak
          # {
          #   environment.systemPackages = [
          #     antigravity-nix.packages.${system}.default
          #   ];
          # }
        ];
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        host: machine:
        mkNixosConfig {
          inherit host;
          profile = machine.profile;
        }
      ) machines;
    };
}
