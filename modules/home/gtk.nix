{ pkgs, lib, ... }:

{
  gtk = {
    enable = true;

    theme = {
      # "Adwaita-dark" 대신 "adw-gtk3"를 사용합니다.
      # 이 테마가 다크모드 지원이 훨씬 완벽합니다.
      name = lib.mkForce "adw-gtk3";
      package = lib.mkForce pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
