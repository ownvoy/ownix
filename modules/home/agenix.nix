# modules/home/agenix.nix
{ inputs, pkgs, ... }:

{
  # 1. NixOS 모듈이 아닌 Home Manager용 agenix 모듈을 불러옵니다.
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  # 2. environment.systemPackages 대신 home.packages를 사용합니다.
  home.packages = [ inputs.agenix.packages.${pkgs.system}.default ];

  # 3. 비밀값 마운트 설정
  age.secrets = {
    "hf-token" = {
      # 상대 경로 주의: modules/home 위치에서 두 칸 위(../../)로 가야 secrets 폴더가 있습니다.
      file = ../../secrets/hf-token.age; 
    };
    "gh-token" = {
      file = ../../secrets/gh-token.age;
    };
  };
}
