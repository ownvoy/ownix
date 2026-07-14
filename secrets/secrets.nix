# ~/ownix/secrets/secrets.nix
let
  # 사용자 키 (wonjun@Wonjuns-MacBook-Air)
  wonjun-mba = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC93SbXbUlGL4iY9B/Vxn5fZ0bC6mYVeuPEDZL3xmaLy wonjun@Wonjuns-MacBook-Air";

  # 사용자 키 (ownvoy@my-desktop)
  ownvoy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOyV9lsQSL3kGsSm4jC+CLZ+86e/LSulSiCBvmdhgJX ownvoy@my-desktop";
  
  # 시스템 호스트 키 (root@nixos-wj)
  nixos-wj = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEF7ZPJEvcQhP9B7El4lUg8+Qqtcq4gCbQQyzAxaiJfE root@nixos-wj";
in
{
  "hf-token.age".publicKeys = [ wonjun-mba ownvoy nixos-wj ];
  "gh-token.age".publicKeys = [ wonjun-mba ownvoy nixos-wj ];
}
