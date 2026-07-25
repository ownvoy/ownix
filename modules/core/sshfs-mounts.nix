{ ... }:
{
  systemd.mounts = [
    {
      description = "SSHFS mount for bai-vscode server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      what = "bai-vscode:/home/work/mlp/wjoh/Standard_Korean_GEC";
      where = "/home/ownvoy/projects/Standard_Korean_GEC";
      type = "fuse.sshfs";
      options = "idmap=user,reconnect,_netdev,IdentityFile=/home/ownvoy/.ssh/id_ed25519,StrictHostKeyChecking=no,ServerAliveInterval=30,kernel_cache,cache_timeout=60,cache_stat_timeout=60,cache_dir_timeout=60";
      # wantedBy = [ "multi-user.target" ];  # 수동으로만 사용 (자동 마운트 안 함)
      mountConfig = {
        TimeoutIdleSec = "0";
      };
    }
  ];
}
