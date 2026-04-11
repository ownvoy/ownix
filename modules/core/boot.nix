{ pkgs, config, lib, ... }: # lib을 추가했습니다.

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; 

    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    
    # 2. Realtek 8852BE 전원 관리 비활성화 옵션 추가
    extraModprobeConfig = ''
      options rtw89_pci disable_aspm=y
      options rtw89_core disable_ps_mode=y
    '';

    kernel.sysctl = { "vm.max_map_count" = 2147483642; };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = true;
  };

  # 3. Tailscale 관련 네트워크 충돌 방지 설정 추가
  networking.firewall.checkReversePath = "loose";
}
