# Lazygit is a simple terminal UI for git commands.
{ config, lib, ... }:
let
  colors =
    if config ? lib && config.lib ? stylix && config.lib.stylix ? colors then
      config.lib.stylix.colors
    else
      {
        base0D = "8aadf4";
        base03 = "5b6078";
      };
  accent = "#${colors.base0D}";
  muted = "#${colors.base03}";
in
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        theme = {
          activeBorderColor = [ accent "bold" ];
          inactiveBorderColor = [ muted ];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
