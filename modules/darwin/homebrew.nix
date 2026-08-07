{ pkgs, username, ... }:
{
  system.primaryUser = username;

  # Chrome's own "hold ⌘Q to quit" confirmation (Chrome menu > Warn Before
  # Quitting) requires the key to be held ~1s, which the clean cmd+q that
  # Karabiner sends for Hyper (Caps Lock) + q (see modules/home/karabiner.nix)
  # doesn't do — it's a single tap. Disable Chrome's own confirmation instead.
  system.defaults.CustomUserPreferences."com.google.Chrome" = {
    ConfirmToQuitEnabled = false;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
    user = username;
    autoMigrate = true;
    trust.taps = [ "koekeishiya/formulae" ];
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
    taps = [ "koekeishiya/formulae" ];
    brews = [
      # mas is used by ./mas-apps.nix (App Store apps are installed there, not
      # via homebrew.masApps — see the comment in that module for why).
      "mas"
      "yabai"
    ];
    casks = [
      "google-chrome"
      "hammerspoon"
      "karabiner-elements"
      "neovide"
      "paseo"
    ];
  };
}
