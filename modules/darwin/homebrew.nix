{ pkgs, username, ... }:
{
  system.primaryUser = username;

  nix-homebrew = {
    enable = true;
    enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
    user = username;
    autoMigrate = true;
    # Re-enable this when using OmniWM again.
    # trust.taps = [ "BarutSRB/tap" ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    # Re-enable this tap when using OmniWM again.
    # taps = [ "BarutSRB/tap" ];
    casks = [
      "discord"
      "google-chrome"
      "hammerspoon"
      "karabiner-elements"
      "neovide"
    ];
  };
}
