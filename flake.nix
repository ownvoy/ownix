{
  description = "Ownix";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    claude-code.url = "github:sadjow/claude-code-nix";
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nvf.url = "github:notashelf/nvf";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Keep the last nixpkgs revision where Zotero 10.0.0 and Firefox ESR
    # 140.14.0 matched. The unstable package has since moved to Zotero 10.0.2
    # and Firefox ESR 153, so use this package directly rather than overriding
    # a removed firefox-esr-140 argument on the new derivation.
    nixpkgs-zotero-gecko.url = "github:NixOS/nixpkgs/09e9eb0b2d7c8c9a3f76b017920aae3bb4f30579";
    agenix.url = "github:ryantm/agenix";
    # Upstream retired its Nix distribution in 49cc5105 (2026-08-31): flake.nix,
    # flake.lock and the whole nix/ dir (incl. the home-manager module we import
    # in modules/home/open-design.nix) were deleted. Pinned to the last rev that
    # still ships them; unpin only if upstream restores a flake.
    open-design.url = "github:nexu-io/open-design/517f39acde402c1a7af2189167a8d6957a3dac71";
    endcord-src = {
      url = "github:sparklost/endcord";
      flake = false;
    };
    # claw-hwp: Claude Code skill for reading/creating/editing Korean HWP/HWPX
    # docs. Consumed as a plain source tree (all JS/Python deps are vendored),
    # placed into ~/.claude/skills by modules/home/claw-hwp.nix.
    claw-hwp = {
      url = "github:DoHyun468/claw-hwp";
      flake = false;
    };
    # hallmark: Claude Code design skill (anti-AI-slop UI generation). Plain
    # markdown + references, placed into ~/.claude/skills by
    # modules/home/hallmark.nix.
    hallmark = {
      url = "github:Nutlope/hallmark";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-homebrew,
      nix-flatpak,
      nixpkgs-unstable,
      agenix,
      hermes-agent,
      paseo,
      # antigravity-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      packageSystems = [
        system
        darwinSystem
      ];
      username = "ownvoy";
      rufloVersion = "3.5.80";
      ouroborosVersion = "0.41.0";
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
            inherit self;
            inherit username;
            inherit host;
            inherit profile;
          };
          modules = [
            ./profiles/${profile}
            nix-flatpak.nixosModules.nix-flatpak
            hermes-agent.nixosModules.default
            # {
            #   environment.systemPackages = [
            #     antigravity-nix.packages.${system}.default
            #   ];
            # }
          ];
        };

      mkDarwinConfig =
        {
          host,
          system,
          username,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit self;
            inherit username;
            inherit host;
          };
          modules = [
            ./modules/darwin
            nix-homebrew.darwinModules.nix-homebrew
          ];
        };
    in
    {
      packages = nixpkgs.lib.genAttrs packageSystems (packageSystem:
      let
        pkgs = nixpkgs.legacyPackages.${packageSystem};
      in
      {
        ruflo = pkgs.writeShellApplication {
          name = "claude-flow";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''
            export npm_config_cache="''${XDG_CACHE_HOME:-$HOME/.cache}/npm"
            export npm_config_fund=false
            export npm_config_update_notifier=false

            exec npx --yes @claude-flow/cli@${rufloVersion} "$@"
          '';
        };

        opencodex = pkgs.callPackage ./pkgs/opencodex { };

        ouroboros = pkgs.writeShellApplication {
          name = "ouroboros";
          runtimeInputs = [
            pkgs.python312
            pkgs.uv
          ];
          text = ''
            export UV_PYTHON="${pkgs.python312}/bin/python3"
            export UV_PYTHON_DOWNLOADS=never
            ${nixpkgs.lib.optionalString pkgs.stdenv.isLinux ''
              export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            ''}

            exec uvx \
              --python "${pkgs.python312}/bin/python3" \
              --from "ouroboros-ai[mcp]==${ouroborosVersion}" \
              ouroboros "$@"
          '';
        };
      });

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        host: machine:
        mkNixosConfig {
          inherit host;
          profile = machine.profile;
        }
      ) machines;

      darwinConfigurations = {
        Wonjuns-MacBook-Air = mkDarwinConfig {
          host = "Wonjuns-MacBook-Air";
          system = darwinSystem;
          username = "wonjun";
        };
      };
    };
}
