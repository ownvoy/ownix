{ host, lib, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) browser;
in
{
  programs.chromium = lib.mkIf (browser == "chromium") {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    ];
  };
}
