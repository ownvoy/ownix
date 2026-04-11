{ config, pkgs, ... }:

{
  # [해결책] 충돌을 피하기 위해 모듈 자체를 비활성화합니다.
  # 대신 아래에서 패키지와 설정을 직접 정의합니다.
  i18n.inputMethod.enable = false; 

  # 1. 패키지 수동 설치 (Addon 포함)
  home.packages = [
    (pkgs.fcitx5-with-addons.override {
      addons = with pkgs; [
        fcitx5-hangul
        fcitx5-gtk
      ];
    })
  ];

  # 2. 환경 변수 설정 (원래 모듈이 해주던 것을 수동으로 설정)
  home.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
  };

  # 3. 설정 파일 생성 (이제 모듈과 충돌하지 않으므로 에러가 나지 않습니다)
  # xdg.configFile = {
  #   # 입력기 순서 설정 (영어 우선)
  #   "fcitx5/profile".text = ''
  #     [Groups/0]
  #     Name=Default
  #     Default Layout=us
  #     DefaultIM=keyboard-us
  #
  #     [Groups/0/Items/0]
  #     Name=keyboard-us
  #     Layout=
  #
  #     [Groups/0/Items/1]
  #     Name=hangul
  #     Layout=
  #
  #     [GroupOrder]
  #     0=Default
  #   '';
  #
  #   # 동작 설정 (화면 표시 끄기)
  #   "fcitx5/config".text = ''
  #     [Behavior]
  #     ShowInputMethodInformation=False
  #   '';
  # };
}
