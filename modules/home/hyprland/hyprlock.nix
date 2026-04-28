{ host, config, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) stylixImage;
  colors = config.lib.stylix.colors;
  sansFont = config.stylix.fonts.sansSerif.name;
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };
      background = [
        {
          path = "${stylixImage}";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "440, 72";
          position = "0, -12";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(${colors.base07})";
          inner_color = "rgba(111317cc)";
          outer_color = "rgb(${colors.base05})";
          check_color = "rgb(${colors.base0B})";
          fail_color = "rgb(${colors.base08})";
          capslock_color = "rgb(${colors.base09})";
          outline_thickness = 3;
          rounding = 14;
          placeholder_text = "Password...";
          fail_text = "$PAMFAIL";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
      ];
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] date '+%H:%M'";
          color = "rgb(${colors.base07})";
          font_size = 104;
          font_family = sansFont;
          text_align = "center";
          position = "0, 188";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 8;
          shadow_color = "rgba(00000088)";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date '+%A, %B %-d'";
          color = "rgba(${colors.base05}dd)";
          font_size = 24;
          font_family = sansFont;
          text_align = "center";
          position = "0, 102";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
