{ config, pkgs, ... }:

{
  # 1. Tailscale 설정
  services.tailscale.enable = true;
  
  # 2. Tailscale 사용 시 발생하는 라우팅 충돌 방지 (중요!)
  networking.firewall.checkReversePath = "loose";

  # 3. DNS 충돌 방지를 위한 resolved 활성화
  services.resolved.enable = true;

  # 4. (이전 답변) Realtek 드라이버 안정화 옵션
  boot.extraModprobeConfig = ''
    options rtw89_pci disable_aspm=y
    options rtw89_core disable_ps_mode=y
  '';

  # 5. 절전 모드 비활성화
  networking.networkmanager.wifi.powersave = false;
}
