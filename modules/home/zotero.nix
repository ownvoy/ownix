{ lib, pkgs, ... }:

{
  xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
    zotero = {
      name = "Zotero";
      genericName = "Bibliographic Research Tool";
      exec = "env GTK_THEME=Adwaita:light zotero %u";
      icon = "zotero";
      comment = "Collect, organize, cite, and share research sources";
      categories = [ "Office" "Database" "Education" ];
      mimeType = [ "x-scheme-handler/zotero" "application/x-research-info-systems" "text/ris" "text/x-research-info-systems" ];
    };
  };
}
