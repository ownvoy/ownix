{
  services.tailscale.enable = true;

  launchd.daemons.tailscaled.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
  };
}
