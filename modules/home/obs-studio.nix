{ pkgs, ... }:
let
  # obs-studio 32.2 이후 obs_properties_add_button 이 deprecated 로 표시됐는데,
  # obs-move-transition 은 최신 릴리스(3.2.1, 2026-02)에서도 여전히 이 API 를
  # 호출한다. OBS 플러그인 템플릿이 -Werror 로 빌드해서 경고가 곧 에러가 되므로,
  # 이 경고만 다시 경고로 낮춘다. 업스트림이 API 를 옮기면 제거할 것.
  obs-move-transition = pkgs.obs-studio-plugins.obs-move-transition.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=deprecated-declarations";
  });
in
{
  programs.obs-studio = {
    enable = true;
    #enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-composite-blur
      obs-backgroundremoval
    ] ++ [ obs-move-transition ];
  };
}
