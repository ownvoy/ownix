{
  bar = {
    autoHideDelay = 500;
    autoShowDelay = 150;
    backgroundOpacity = 0.93;
    barType = "floating";
    capsuleColorKey = "none";
    capsuleOpacity = 1;
    contentPadding = 2;
    density = "default";
    displayMode = "always_visible";
    enableExclusionZoneInset = true;
    fontScale = 1;
    frameRadius = 12;
    frameThickness = 8;
    hideOnOverview = false;
    marginHorizontal = 4;
    marginVertical = 4;
    middleClickAction = "none";
    middleClickCommand = "";
    middleClickFollowMouse = false;
    monitors = [ ];
    mouseWheelAction = "none";
    mouseWheelWrap = true;
    outerCorners = true;
    position = "top";
    reverseScroll = false;
    rightClickAction = "controlCenter";
    rightClickCommand = "";
    rightClickFollowMouse = true;
    screenOverrides = [ ];
    showCapsule = true;
    showOnWorkspaceSwitch = true;
    showOutline = false;
    useSeparateOpacity = false;
    widgetSpacing = 6;
    widgets = {
      center = [
        {
          characterCount = 2;
          colorizeIcons = false;
          emptyColor = "secondary";
          enableScrollWheel = true;
          focusedColor = "primary";
          followFocusedScreen = false;
          fontWeight = "bold";
          groupedBorderOpacity = 1;
          hideUnoccupied = false;
          iconScale = 0.8;
          id = "Workspace";
          labelMode = "index";
          occupiedColor = "secondary";
          pillSize = 0.6;
          showApplications = false;
          showApplicationsHover = false;
          showBadge = true;
          showLabelsOnlyWhenOccupied = true;
          unfocusedIconsOpacity = 1;
        }
      ];
      left = [
        {
          colorizeSystemIcon = "none";
          colorizeSystemText = "none";
          customIconPath = "";
          enableColorization = false;
          icon = "rocket";
          iconColor = "none";
          id = "Launcher";
          useDistroLogo = false;
        }
        {
          clockColor = "none";
          customFont = "";
          formatHorizontal = "HH:mm ddd, MMM dd";
          formatVertical = "HH mm - dd MM";
          id = "Clock";
          tooltipFormat = "HH:mm ddd, MMM dd";
          useCustomFont = false;
        }
        {
          compactMode = true;
          diskPath = "/";
          iconColor = "none";
          id = "SystemMonitor";
          showCpuCores = false;
          showCpuFreq = false;
          showCpuTemp = true;
          showCpuUsage = true;
          showDiskAvailable = false;
          showDiskUsage = false;
          showDiskUsageAsPercent = false;
          showGpuTemp = false;
          showLoadAverage = false;
          showMemoryAsPercent = false;
          showMemoryUsage = true;
          showNetworkStats = false;
          showSwapUsage = false;
          textColor = "none";
          useMonospaceFont = true;
          usePadding = false;
        }
        {
          colorizeIcons = false;
          hideMode = "hidden";
          id = "ActiveWindow";
          maxWidth = 145;
          scrollingMode = "hover";
          showIcon = true;
          showText = true;
          textColor = "none";
          useFixedWidth = false;
        }
        {
          compactMode = false;
          hideMode = "hidden";
          hideWhenIdle = false;
          id = "MediaMini";
          maxWidth = 145;
          panelShowAlbumArt = true;
          scrollingMode = "hover";
          showAlbumArt = true;
          showArtistFirst = true;
          showProgressRing = true;
          showVisualizer = false;
          textColor = "none";
          useFixedWidth = false;
          visualizerType = "linear";
        }
      ];
      right = [
        {
          blacklist = [ ];
          chevronColor = "none";
          colorizeIcons = false;
          drawerEnabled = true;
          hidePassive = false;
          id = "Tray";
          pinned = [ ];
        }
        {
          hideWhenZero = false;
          hideWhenZeroUnread = false;
          iconColor = "none";
          id = "NotificationHistory";
          showUnreadBadge = true;
          unreadBadgeColor = "primary";
        }
        {
          deviceNativePath = "__default__";
          displayMode = "graphic-clean";
          hideIfIdle = false;
          hideIfNotDetected = true;
          id = "Battery";
          showNoctaliaPerformance = false;
          showPowerProfiles = false;
        }
        {
          displayMode = "onhover";
          iconColor = "none";
          id = "Volume";
          middleClickCommand = "pwvucontrol || pavucontrol";
          textColor = "none";
        }
        {
          applyToAllMonitors = false;
          displayMode = "onhover";
          iconColor = "none";
          id = "Brightness";
          textColor = "none";
        }
        {
          colorizeDistroLogo = false;
          colorizeSystemIcon = "none";
          colorizeSystemText = "none";
          customIconPath = "";
          enableColorization = false;
          icon = "noctalia";
          id = "ControlCenter";
          useDistroLogo = false;
        }
      ];
    };
  };
}
