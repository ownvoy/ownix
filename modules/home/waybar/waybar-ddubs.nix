{ pkgs
, lib
, host
, config
, ...
}:
let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  panelBg = "rgba(54, 54, 61, 0.20)";
  surface = "36363d";
  surfaceHover = "50655c";
  border = "4b5d56";
  text = "d6dcc8";
  textMuted = "a8b09f";
  accent = "b69860";
  accentSoft = "5e8675";
  accentWarm = "947551";
  danger = "c77967";
  inherit (import ../../../hosts/${host}/variables.nix) clock24h;
in
with lib; {
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "hyprland/window"
          "pulseaudio"
          "cpu"
          "memory"
          "idle_inhibitor"
        ];
        modules-right = [
          "custom/notification"
          "custom/exit"
          "battery"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}{windows}";
          format-icons = {
            active = "";
            default = "";
            urgent = "";
          };
          format-window-separator = "";
          workspace-taskbar = {
            enable = true;
            icon-size = 16;
            icon-theme = "Papirus-Dark";
            update-active-window = true;
            active-window-position = "first";
            format = "{icon}";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format =
            if clock24h == true
            then '' {:L%H:%M}''
            else '' {:L%I:%M %p}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
        };
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "";
          # exec = "rofi -show drun";
          #on-click = "sleep 0.1 && rofi-launcher";
          on-click = "sleep 0.1 && nwg-drawer -mb 200 -mt 200 -mr 200 -ml 200";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = false;
        };
      }
    ];
    style = concatStrings [
      ''
        * {
          font-family: Cascadia Code NF;
          font-size: 18px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: ${panelBg};
        }
        #workspaces {
          color: #${text};
          background: rgba(54, 54, 61, 0.92);
          margin: 4px 4px;
          padding: 5px 6px;
          border-radius: 16px;
          border: 1px solid #${border};
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 8px;
          margin: 0px 1px;
          border-radius: 16px;
          color: #${textMuted};
          background: transparent;
          opacity: 1;
          transition: ${betterTransition};
        }
        #workspaces button box {
          margin: 0px;
        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 10px;
          margin: 0px 1px;
          border-radius: 16px;
          color: #1f2123;
          background: linear-gradient(135deg, #${accentWarm}, #${accent});
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${text};
          background: #${surfaceHover};
          opacity: 1;
          transition: ${betterTransition};
        }
        #workspaces .workspace-label {
          margin-right: 2px;
        }
        #workspaces .workspace-label,
        #workspaces .taskbar-window {
          padding: 0px;
        }
        #workspaces .taskbar-window {
          margin-left: 0px;
          margin-right: 0px;
        }
        #workspaces .taskbar-window image {
          min-width: 16px;
          min-height: 16px;
        }
        tooltip {
          background: #${surface};
          border: 1px solid #${border};
          border-radius: 12px;
        }
        tooltip label {
          color: #${text};
        }
        #window, #pulseaudio, #cpu, #memory, #idle_inhibitor {
          font-weight: bold;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 18px;
          background: #${surface};
          color: #${text};
          border-radius: 8px 8px 8px 8px;
          border: 1px solid #${border};
        }
        #idle_inhibitor {
          font-size: 28px;
          color: #${accentSoft};
        }
        #custom-startmenu {
          color: #1f2123;
          background: #${accentSoft};
          font-size: 22px;
          margin: 4px 0px 4px 6px;
          padding: 0px 10px;
          border-radius: 16px 16px 16px 16px;
          border: 1px solid rgba(255, 255, 255, 0.08);
        }
        #network, #battery, #custom-notification, #tray, #custom-exit {
          /* font-weight: bold; */
          font-size: 20px;
          background: #${surface};
          color: #${textMuted};
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 8px 8px 8px 8px;
          padding: 0px 18px;
          border: 1px solid #${border};
        }
        #pulseaudio, #clock {
          color: #${accentWarm};
        }
        #cpu, #memory, #window {
          color: #${text};
        }
        #network, #idle_inhibitor {
          color: #${accentSoft};
        }
        #battery {
          color: #${accent};
        }
        #battery.warning, #battery.critical, #custom-exit {
          color: #${danger};
        }
        #clock {
          font-weight: bold;
          font-size: 16px;
          color: #1f2123;
          background: linear-gradient(135deg, #${accentWarm}, #${accent});
          margin: 4px 6px 4px 0px;
          padding: 0px 12px;
          border-radius: 16px 16px 16px 16px;
          border: 1px solid rgba(255, 255, 255, 0.08);
        }
      ''
    ];
  };
}
