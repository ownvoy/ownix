{
  notifications = {
    backgroundOpacity = 1;
    clearDismissed = true;
    criticalUrgencyDuration = 15;
    density = "default";
    enableBatteryToast = true;
    enableKeyboardLayoutToast = true;
    enableMarkdown = false;
    enableMediaToast = false;
    enabled = true;
    location = "top_right";
    lowUrgencyDuration = 3;
    monitors = [ ];
    normalUrgencyDuration = 8;
    overlayLayer = true;
    respectExpireTimeout = false;
    saveToHistory = {
      critical = true;
      low = true;
      normal = true;
    };
    sounds = {
      criticalSoundFile = "";
      enabled = false;
      excludedApps = "discord,firefox,chrome,chromium,edge";
      lowSoundFile = "";
      normalSoundFile = "";
      separateSounds = false;
      volume = 0.5;
    };
  };

  sessionMenu = {
    countdownDuration = 10000;
    enableCountdown = true;
    largeButtonsLayout = "single-row";
    largeButtonsStyle = true;
    position = "center";
    powerOptions = [
      {
        action = "lock";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "1";
      }
      {
        action = "suspend";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "2";
      }
      {
        action = "hibernate";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "3";
      }
      {
        action = "reboot";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "4";
      }
      {
        action = "logout";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "5";
      }
      {
        action = "shutdown";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "6";
      }
      {
        action = "rebootToUefi";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "7";
      }
      {
        action = "userspaceReboot";
        command = "";
        countdownEnabled = true;
        enabled = false;
        keybind = "";
      }
    ];
    showHeader = true;
    showKeybinds = true;
  };
}
