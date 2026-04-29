{ terminal }:
{
  appLauncher = {
    autoPasteClipboard = false;
    clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
    clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
    clipboardWrapText = true;
    customLaunchPrefix = "";
    customLaunchPrefixEnabled = false;
    density = "default";
    enableClipPreview = true;
    enableClipboardChips = true;
    enableClipboardHistory = true;
    enableClipboardSmartIcons = true;
    enableSessionSearch = true;
    enableSettingsSearch = true;
    enableWindowsSearch = true;
    iconMode = "tabler";
    ignoreMouseInput = false;
    overviewLayer = false;
    pinnedApps = [ ];
    position = "center";
    screenshotAnnotationTool = "";
    showCategories = true;
    showIconBackground = false;
    sortByMostUsed = true;
    terminalCommand = "${terminal} -e";
    viewMode = "list";
  };

  audio = {
    mprisBlacklist = [ ];
    preferredPlayer = "";
    spectrumFrameRate = 30;
    spectrumMirrored = true;
    visualizerType = "linear";
    volumeFeedback = false;
    volumeFeedbackSoundFile = "";
    volumeOverdrive = false;
    volumeStep = 5;
  };

  brightness = {
    backlightDeviceMappings = [ ];
    brightnessStep = 5;
    enableDdcSupport = false;
    enforceMinimum = true;
  };

  network = {
    bluetoothAutoConnect = true;
    bluetoothDetailsViewMode = "grid";
    bluetoothHideUnnamedDevices = false;
    bluetoothRssiPollIntervalMs = 60000;
    bluetoothRssiPollingEnabled = false;
    disableDiscoverability = false;
    networkPanelView = "wifi";
    wifiDetailsViewMode = "grid";
  };

  nightLight = {
    autoSchedule = true;
    dayTemp = "6500";
    enabled = false;
    forced = false;
    manualSunrise = "06:30";
    manualSunset = "18:30";
    nightTemp = "4000";
  };
}
