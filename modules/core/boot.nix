{ pkgs, config, lib, ... }: # lib을 추가했습니다.

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; 

    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # This AMD Rembrandt (Radeon 680M) box hangs on reboot: it powers off and
    # back on but never re-POSTs (black screen); only a full cold boot recovers.
    # Force the kernel's reboot method to do a full hardware reset. If "pci"
    # doesn't fix it, try these values in order (rebuild + reboot each time):
    #   "bios" -> "acpi" -> "efi" -> "pci,hard" -> "hard" -> "cold" -> "warm"
    kernelParams = [ "reboot=pci" ];
    
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
