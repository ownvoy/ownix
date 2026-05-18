{ config, lib, pkgs, ... }:
let
  dwProtonVersion = "10.0-26";

  dwProton = pkgs.stdenvNoCC.mkDerivation {
    pname = "dw-proton";
    version = dwProtonVersion;

    src = pkgs.fetchurl {
      url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${dwProtonVersion}/dwproton-${dwProtonVersion}-x86_64.tar.xz";
      hash = "sha256-p7WGDt2JJX208VW0w9ozHolGBNNKEmDa71cZJy+r8Z8=";
    };

    dontUnpack = true;
    nativeBuildInputs = [ pkgs.xz ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/steam/compatibilitytools.d/dwproton-${dwProtonVersion}"
      tar -xJf "$src" \
        --strip-components=1 \
        -C "$out/share/steam/compatibilitytools.d/dwproton-${dwProtonVersion}"

      runHook postInstall
    '';
  };
in
{
  home.file.".steam/root/compatibilitytools.d/dwproton-${dwProtonVersion}".source =
    "${dwProton}/share/steam/compatibilitytools.d/dwproton-${dwProtonVersion}";

  home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    "${config.home.homeDirectory}/.steam/root/compatibilitytools.d";
}
