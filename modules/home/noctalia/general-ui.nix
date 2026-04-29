{ username }:
{
  general = {
    allowPanelsOnScreenWithoutBar = true;
    allowPasswordWithFprintd = false;
    animationDisabled = false;
    animationSpeed = 1;
    autoStartAuth = false;
    avatarImage = "/home/${username}/.face";
    boxRadiusRatio = 1;
    clockFormat = "hh\\nmmMM/dd/yyyy ";
    clockStyle = "custom";
    compactLockScreen = false;
    dimmerOpacity = 0.2;
    enableBlurBehind = true;
    enableLockScreenCountdown = true;
    enableLockScreenMediaControls = false;
    enableShadows = true;
    forceBlackScreenCorners = false;
    iRadiusRatio = 1;
    keybinds = {
      keyDown = [ "Down" ];
      keyEnter = [ "Return" "Enter" ];
      keyEscape = [ "Esc" ];
      keyLeft = [ "Left" ];
      keyRemove = [ "Del" ];
      keyRight = [ "Right" ];
      keyUp = [ "Up" ];
    };
    language = "";
    lockOnSuspend = true;
    lockScreenAnimations = true;
    lockScreenBlur = 0;
    lockScreenCountdownDuration = 10000;
    lockScreenMonitors = [ ];
    lockScreenTint = 0;
    passwordChars = true;
    radiusRatio = 1;
    reverseScroll = false;
    scaleRatio = 1;
    screenRadiusRatio = 1;
    shadowDirection = "bottom_right";
    shadowOffsetX = 2;
    shadowOffsetY = 3;
    showChangelogOnStartup = true;
    showHibernateOnLockScreen = false;
    showScreenCorners = false;
    showSessionButtonsOnLockScreen = true;
    smoothScrollEnabled = true;
    telemetryEnabled = false;
  };

  ui = {
    boxBorderEnabled = false;
    fontDefault = "Cascadia Code NF SemiBold";
    fontDefaultScale = 1;
    fontFixed = "Cascadia Mono NF";
    fontFixedScale = 1;
    panelBackgroundOpacity = 0.93;
    panelsAttachedToBar = true;
    scrollbarAlwaysVisible = true;
    settingsPanelMode = "attached";
    settingsPanelSideBarCardStyle = false;
    tooltipsEnabled = true;
    translucentWidgets = false;
  };

  idle = {
    customCommands = "[]";
    enabled = false;
    fadeDuration = 5;
    lockCommand = "";
    lockTimeout = 660;
    resumeLockCommand = "";
    resumeScreenOffCommand = "";
    resumeSuspendCommand = "";
    screenOffCommand = "";
    screenOffTimeout = 600;
    suspendCommand = "";
    suspendTimeout = 1800;
  };

  hooks = {
    colorGeneration = "";
    darkModeChange = "";
    enabled = false;
    performanceModeDisabled = "";
    performanceModeEnabled = "";
    screenLock = "";
    screenUnlock = "";
    session = "";
    startup = "";
    wallpaperChange = "";
  };

  osd = {
    autoHideMs = 2000;
    backgroundOpacity = 1;
    enabled = true;
    enabledTypes = [ 0 1 2 ];
    location = "top_right";
    monitors = [ ];
    overlayLayer = true;
  };

  plugins = {
    autoUpdate = false;
    notifyUpdates = true;
  };

  templates = {
    activeTemplates = [ ];
    enableUserTheming = false;
  };

  settingsVersion = 59;
}
