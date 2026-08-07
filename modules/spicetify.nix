{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

  # nixpkgs' spicetify-cli 2.44.0 is missing jsHelper/spicetifyWrapper.js
  # (upstream now generates it with esbuild at build time), which makes the
  # patched Spotify render a black screen. Backport the fix from
  # https://github.com/NixOS/nixpkgs/issues/540406 until our nixpkgs pin
  # includes it.
  spicetify-cli-fixed = pkgs.spicetify-cli.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.esbuild ];
    postBuild = (old.postBuild or "") + ''
      esbuild ./src/jsHelper/spicetifyWrapper/index.js \
        --bundle --minify --target=chrome108 --format=iife \
        --outfile=spicetifyWrapper.js
    '';
    postInstall = (old.postInstall or "") + ''
      chmod -R u+w $out/share/spicetify/jsHelper
      cp spicetifyWrapper.js $out/share/spicetify/jsHelper/spicetifyWrapper.js
    '';
  });
in
{
  programs.spicetify = {
    enable = true;
    spicetifyPackage = spicetify-cli-fixed;
    # Matches the Gruvbox dark palette used in kitty/neovim on darwin.
    # mkDefault so stylix's spicetify target wins on NixOS, where the
    # system-wide palette comes from the wallpaper instead.
    theme = lib.mkDefault spicePkgs.themes.text;
    colorScheme = lib.mkDefault "Gruvbox";
  };
}
