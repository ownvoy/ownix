{ username }:
# Noctalia v5 config (TOML schema). See https://docs.noctalia.dev/v5 and the
# shipped example.toml for the full option list. This attrset is rendered to
# ~/.config/noctalia/config.toml by the home module; it is the source of truth
# on (re)start. Runtime tweaks via the Settings menu are overwritten on rebuild.
{
  accessibility = {
    ui_scale = 1.0;
    high_contrast = false;
  };

  shell = {
    font_family = "Cascadia Code NF";
    time_format = "{:%H:%M}";
    date_format = "%A, %x";
    settings_show_advanced = true;
    telemetry_enabled = false;
    clipboard_enabled = true;
    polkit_agent = false;
  };

  theme = {
    mode = "dark";
    source = "builtin";
    builtin = "Gruvbox";
    pure_black_dark = false;
  };

  # ── Bar ──────────────────────────────────────────────────────────────────
  # Mirrors the old layout: launcher/clock/system/window/media on the left,
  # workspaces centered, status widgets on the right.
  bar.main = {
    position = "top";
    thickness = 34;
    background_opacity = 1.0;
    radius = 12;
    padding = 14;
    widget_spacing = 6;
    shadow = true;
    auto_hide = false;
    reserve_space = true;

    start = [ "launcher" "clock" "sysmon" "active_window" "media" ];
    center = [ "workspaces" ];
    end = [ "tray" "notifications" "clipboard" "volume" "brightness" "battery" "control-center" "session" ];
  };

  # ── Dock ─────────────────────────────────────────────────────────────────
  dock = {
    enabled = true;
    position = "bottom";
    icon_size = 48;
    background_opacity = 0.63;
    radius = 16;
    shadow = true;
    show_running = true;
    auto_hide = true;
    reserve_space = false;
    magnification = true;
    magnification_scale = 1.45;
    active_monitor_only = true;
    launcher_position = "end";
  };

  # ── Wallpaper ────────────────────────────────────────────────────────────
  wallpaper = {
    enabled = true;
    fill_mode = "crop";
    directory = "/home/${username}/ownix/wallpapers";
    transition = [ "fade" "wipe" "disc" "stripes" "honeycomb" ];
    transition_duration = 1500;
  };

  wallpaper.automation = {
    enabled = false;
    order = "random";
  };

  # ── Notifications / OSD ──────────────────────────────────────────────────
  notification = {
    enable_daemon = true;
    show_app_name = true;
    show_actions = true;
    layer = "top";
    background_opacity = 1.0;
  };

  osd = {
    position = "top_right";
    background_opacity = 1.0;
  };

  # ── Weather / Location ───────────────────────────────────────────────────
  weather = {
    enabled = true;
    refresh_minutes = 30;
    unit = "celsius";
    effects = true;
  };

  location = {
    auto_locate = false;
    address = "Daejeon, South Korea";
  };

  # ── System monitor sampling ──────────────────────────────────────────────
  system.monitor.enabled = true;

  # ── Per-widget config ────────────────────────────────────────────────────
  widget.clock = {
    format = "{:%H:%M}";
    tooltip_format = "{:%A, %B %d, %Y}";
  };

  widget.sysmon = {
    stat = "cpu_usage";
    display = "text";
  };
}
