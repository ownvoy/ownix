{ pkgs, ... }: {
  # Sunshine 서비스 활성화
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Wayland 화면 캡처 권한 등을 위해 필요
    openFirewall = true; # 방화벽 자동 개방
  };
}
