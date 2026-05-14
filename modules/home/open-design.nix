{
  config,
  host,
  inputs,
  pkgs,
  ...
}:
let
  openDesignPort = 7457;
  openDesignWebPort = 5174;
  openDesignAllowedOrigins = [
    "http://127.0.0.1:${toString openDesignWebPort}"
    "http://localhost:${toString openDesignWebPort}"
    "http://${host}:${toString openDesignWebPort}"
  ];

  openDesignCaddyfile = pkgs.writeText "open-design-web.Caddyfile" ''
    {
      auto_https off
      admin off
      persist_config off
    }

    http://127.0.0.1:${toString openDesignWebPort}, http://localhost:${toString openDesignWebPort}, http://${host}:${toString openDesignWebPort} {
      handle /api/* {
        reverse_proxy 127.0.0.1:${toString openDesignPort} {
          flush_interval -1
          transport http {
            read_timeout 86400s
            write_timeout 86400s
          }
        }
      }
      handle /artifacts/* {
        reverse_proxy 127.0.0.1:${toString openDesignPort}
      }
      handle /frames/* {
        reverse_proxy 127.0.0.1:${toString openDesignPort}
      }
      handle {
        root * ${config.services.open-design.webFrontend.package}
        try_files {path} {path}/ /index.html
        file_server
        encode gzip
      }
    }
  '';
in
{
  imports = [ inputs.open-design.homeManagerModules.default ];

  services.open-design = {
    enable = true;
    autoStart = true;
    webFrontend = {
      enable = false;
      allowedOrigins = openDesignAllowedOrigins;
    };
  };

  systemd.user.services.open-design-web = {
    Unit = {
      Description = "Open Design web frontend (custom HTTP static file server)";
      After = [ "network-online.target" "open-design.service" ];
      Wants = [ "network-online.target" ];
    };

    Install.WantedBy = [ "default.target" ];

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.caddy}/bin/caddy run --config ${openDesignCaddyfile} --adapter caddyfile";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "opendesign" ''
      set -eu

      systemctl --user start open-design open-design-web
      exec ${pkgs.xdg-utils}/bin/xdg-open http://127.0.0.1:5174
    '')
  ];

  xdg.desktopEntries.opendesign = {
    name = "OpenDesign";
    genericName = "AI Design Tool";
    comment = "Start Open Design and open it in your browser";
    exec = "opendesign";
    terminal = false;
    categories = [ "Graphics" "Development" ];
  };
}
