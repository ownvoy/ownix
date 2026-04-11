{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          # lock_cmd = "hyprlock"; # 주석 처리하거나 삭제
        };
        listener = [
          # 1. 900초(15분) 후 hyprlock 실행 부분 삭제 또는 주석 처리
          # {
          #   timeout = 900;
          #   on-timeout = "hyprlock";
          # }

          # 2. 1200초(20분) 후 모니터만 끄는 기능은 유지 (권장)
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
