# Hyprland Keybindings — ddubsOS

## 🗝️ Conventions
- SUPERKEY = Mod key (Hyprland `$modifier`)
- SHIFT, CTRL, ALT used as shown
- Arrows and hjkl are both supported for movement

---

## 🚀 Applications
- SUPERKEY+Return — Launch default terminal (${terminal})
- SUPERKEY+SHIFT+Return — Launch foot (floating)
- SUPERKEY+ALT+Return — Launch WezTerm
- SUPERKEY+CTRL+Return — Launch Ghostty
- SUPERKEY+W — Launch browser (${browser})
- SUPERKEY+Y — Kitty running Yazi (file manager)
- SUPERKEY+T — Thunar (also another mapping present: "exec, exec, thunar")
- SUPERKEY+M — Pavucontrol (audio)
- SUPERKEY+G — VS Code
- SUPERKEY+O — OBS Studio
- SUPERKEY+E — Emoji picker (emopicker9000)
- SUPERKEY+V — Clipboard menu (cliphist via rofi)
- SUPERKEY+D — Rofi menu
- SUPERKEY+SHIFT+D — Dock
- SUPERKEY+CTRL+D — Sherlock (alt menu)
- SUPERKEY+SHIFT+W — Web search
- SUPERKEY+ALT+W — Warp terminal (commented alternative: wallsetter)
- SUPERKEY+CTRL+W — Waypaper
- SUPERKEY+N — Note from clipboard
- SUPERKEY+SHIFT+N — SwayNC reset
- SUPERKEY+ALT+D — Discord Canary
- SUPERKEY+C — Hyprpicker (color picker)
- SHIFT+ALT+S — Hyprshot region (non-SUPER shortcut)

## 🧭 Hyprland UI/Plugins
- SUPERKEY+/ — List keybinds
- SUPERKEY+TAB — Hyprspace Overview toggle (all)
- SUPERKEY+SHIFT+TAB — Hyprspace Overview close (all)
- ALT+Space — Hyprexpo toggle
- SUPERKEY+A — AGS Overview toggle

## 📸 Screenshots
- SUPERKEY+SHIFT+S — screenshootin
- SUPERKEY+ALT+S — hyprpanel toggleWindow settings-dialog

## 🪟 Window Management
- SUPERKEY+Q — Kill active window
- SUPERKEY+P — Pseudo tile
- SUPERKEY+SHIFT+I — Toggle split
- SUPERKEY+F — Fullscreen
- SUPERKEY+SHIFT+F — Toggle floating
- SUPERKEY+ALT+F — Workspace option: allfloat
- SUPERKEY+SHIFT+C — Exit Hyprland
- SUPERKEY+SPACE — Toggle floating
- SUPERKEY+SHIFT+SPACE — Workspace option: allfloat
- SUPERKEY+SHIFT+M — swap_layout

### Move Window
- SUPERKEY+SHIFT+Left/Right/Up/Down — Move window L/R/U/D
- SUPERKEY+SHIFT+H/J/K/L — Move window L/D/U/R

### Swap Window
- SUPERKEY+ALT+Left/Right/Up/Down — Swap window L/R/U/D
- SUPERKEY+ALT+[, . , - , ,] — Swap window L/R/U/D (keycodes 43,46,45,44)

### Focus Movement
- SUPERKEY+Left/Right/Up/Down — Focus L/R/U/D
- SUPERKEY+H/J/K/L — Focus L/D/U/R

### Workspace Navigation
- SUPERKEY+1..9,0 — Go to workspace 1..10
- SUPERKEY+SHIFT+1..9,0 — Move window to workspace 1..10
- SUPERKEY+CTRL+Right/Left — Next/Previous workspace (relative)
- SUPERKEY+Mouse Wheel Down/Up — Workspace e+1 / e-1

### Alt-Tab
- ALT+Tab — Cycle next
- ALT+Tab — Bring active to top (runs twice to ensure raise)

## 🔊 Media & Brightness
- XF86AudioRaiseVolume — wpctl set-volume +5%
- XF86AudioLowerVolume — wpctl set-volume -5%
- XF86AudioMute — toggle sink mute
- XF86AudioPlay/Pause — playerctl play-pause
- XF86AudioNext/Prev — playerctl next/previous
- XF86MonBrightnessDown/Up — brightnessctl -5% / +5%

## 🖱️ Mouse Bindings
- SUPERKEY + Left Mouse — Move window
- SUPERKEY + Right Mouse — Resize window
