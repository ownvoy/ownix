{
  gitUsername = "ownvoy";
  gitEmail = "ownvoy@g.skku.edu";

  displayManager = "sddm";

  tmuxEnable = true;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;
  vscodeEnable = true;
  helixEnable = false;
  doomEmacsEnable = false;

  extraMonitorSettings = "";

  clock24h = false;
  desktopShell = "noctalia";

  browser = "chromium";
  terminal = "kitty";

  keyboardLayout = "us";
  consoleKeyMap = "us";

  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  enableNFS = true;
  printEnable = false;
  thunarEnable = true;

  stylixImage = ../../wallpapers/girl-vs-monster.jpg;
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  animChoice = ../../modules/home/hyprland/animations-dynamic.nix;

  hostId = "00000000";
}
