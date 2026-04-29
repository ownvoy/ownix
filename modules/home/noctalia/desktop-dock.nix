{
  desktopWidgets = {
    enabled = true;
    gridSnap = false;
    gridSnapScale = false;
    monitorWidgets = [ ];
    overviewEnabled = true;
  };

  dock = {
    animationSpeed = 1;
    backgroundOpacity = 0.63;
    colorizeIcons = false;
    deadOpacity = 0.6;
    displayMode = "auto_hide";
    dockType = "floating";
    enabled = true;
    floatingRatio = 1;
    groupApps = false;
    groupClickAction = "cycle";
    groupContextMenuMode = "extended";
    groupIndicatorStyle = "dots";
    inactiveIndicators = false;
    indicatorColor = "none";
    indicatorOpacity = 0.6;
    indicatorThickness = 3;
    launcherIcon = "";
    launcherIconColor = "none";
    launcherPosition = "end";
    launcherUseDistroLogo = false;
    monitors = [ ];
    onlySameOutput = true;
    pinnedApps = [ ];
    pinnedStatic = false;
    position = "bottom";
    showDockIndicator = true;
    showLauncherIcon = true;
    sitOnFrame = false;
    size = 1;
  };

  colorSchemes = {
    darkMode = true;
    generationMethod = "tonal-spot";
    manualSunrise = "06:30";
    manualSunset = "18:30";
    monitorForColors = "";
    predefinedScheme = "Gruvbox";
    schedulingMode = "off";
    syncGsettings = true;
    useWallpaperColors = false;
  };

  noctaliaPerformance = {
    disableDesktopWidgets = true;
    disableWallpaper = true;
  };

  systemMonitor = {
    batteryCriticalThreshold = 5;
    batteryWarningThreshold = 20;
    cpuCriticalThreshold = 90;
    cpuWarningThreshold = 80;
    criticalColor = "";
    diskAvailCriticalThreshold = 10;
    diskAvailWarningThreshold = 20;
    diskCriticalThreshold = 90;
    diskWarningThreshold = 80;
    enableDgpuMonitoring = false;
    externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
    gpuCriticalThreshold = 90;
    gpuWarningThreshold = 80;
    memCriticalThreshold = 90;
    memWarningThreshold = 80;
    swapCriticalThreshold = 90;
    swapWarningThreshold = 80;
    tempCriticalThreshold = 90;
    tempWarningThreshold = 80;
    useCustomColors = false;
    warningColor = "";
  };
}
