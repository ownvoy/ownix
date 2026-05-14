{
  services = {
    hanbat-a100 = {
      type = "sftp";
      host = "210.110.250.120";
      user = "user";
      port = 16022;
    };

    seoultech-h100 = {
      type = "sftp";
      host = "117.17.185.235";
      user = "seoultech";
      port = 22;
    };

    seoultech-a6000 = {
      type = "sftp";
      host = "117.17.185.27";
      user = "user";
      port = 22;
    };

    a6000 = {
      type = "sftp";
      host = "117.17.185.27";
      user = "user";
      port = 25565;
    };

    h200-up-up = {
      type = "sftp";
      host = "13.124.117.51";
      user = "ec2-user";
      port = 22;
      key_file = "~/.ssh/kaist.pem";
    };

    h100-proxy = {
      type = "sftp";
      host = "127.0.0.1";
      user = "seoultech";
      port = 10022;
    };
  };
}
