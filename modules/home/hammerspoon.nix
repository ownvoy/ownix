{ ... }:
{
  # Hammerspoon itself is installed via the "hammerspoon" homebrew cask
  # (see modules/darwin/homebrew.nix) — it needs to be a signed .app in
  # /Applications to be granted Accessibility permissions.
  home.file.".hammerspoon/init.lua".text = ''
    -- Managed by nix (modules/home/hammerspoon.nix) — edit there, not here.
    hs.window.animationDuration = 0

    -- Reload config whenever any file under ~/.hammerspoon changes.
    hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()

    ------------------------------------------------------------------
    -- App launcher / focus-toggle hotkeys.
    -- Mirrors the super+g / super+d / super+t style from Linux: bound to
    -- both a plain alt+cmd chord and the Hyper key (Caps Lock, held, via
    -- Karabiner-Elements — see modules/home/karabiner.nix) so it still
    -- works before Karabiner's permissions are granted.
    ------------------------------------------------------------------
    local hyperMod = { "cmd", "alt", "ctrl", "shift" } -- Hyper key (Caps Lock)
    local appMods = {
      { "alt", "cmd" },
      hyperMod,
    }

    local function toggleApp(name)
      local app = hs.application.find(name)
      if app and app:isFrontmost() then
        app:hide()
      else
        hs.application.launchOrFocus(name)
      end
    end

    local function bindApp(key, fn)
      for _, mod in ipairs(appMods) do
        hs.hotkey.bind(mod, key, fn)
      end
    end

    bindApp("G", function()
      hs.urlevent.openURL("https://www.google.com")
    end)
    bindApp("M", function() toggleApp("Discord") end)
    bindApp("T", function() toggleApp("kitty") end)
    bindApp("Y", function()
      hs.execute("open -na kitty --args -e yazi", true)
    end)
    bindApp("O", function() toggleApp("Obsidian") end)

    bindApp("R", hs.reload)

    -- Hyper (Caps Lock) + c/v/q/e -> clean cmd+c / cmd+v / cmd+q / cmd+ctrl+space
    -- is handled directly in Karabiner-Elements (see modules/home/karabiner.nix),
    -- not here — Karabiner cleanly overrides the held modifiers per-event,
    -- while Hammerspoon's synthetic keystrokes let the extra ctrl/alt/shift
    -- from the still-held Caps Lock leak through to the target app.

    ------------------------------------------------------------------
    -- Window management (Hyper key only, single modifier) -- delegates to
    -- yabai, which owns actual tiling/layout (see modules/home/yabai.nix).
    -- Hammerspoon is just a hotkey -> `yabai -m ...` shell-out layer here.
    -- Mirrors the $modifier-based hjkl/arrow/number scheme from the
    -- my-desktop Hyprland config (modules/home/hyprland/binds.nix), with
    -- Caps Lock standing in for Hyprland's Super key.
    ------------------------------------------------------------------
    local yabai = "/opt/homebrew/bin/yabai"

    local function yabaiCmd(args)
      return function() hs.execute(yabai .. " " .. args, true) end
    end

    -- focus window in a direction (mirrors $modifier+hjkl,movefocus)
    hs.hotkey.bind(hyperMod, "H", yabaiCmd("-m window --focus west"))
    hs.hotkey.bind(hyperMod, "J", yabaiCmd("-m window --focus south"))
    hs.hotkey.bind(hyperMod, "K", yabaiCmd("-m window --focus north"))
    hs.hotkey.bind(hyperMod, "L", yabaiCmd("-m window --focus east"))

    -- move window in a direction (mirrors $modifier SHIFT+arrows,movewindow)
    hs.hotkey.bind(hyperMod, "Left",  yabaiCmd("-m window --swap west"))
    hs.hotkey.bind(hyperMod, "Right", yabaiCmd("-m window --swap east"))
    hs.hotkey.bind(hyperMod, "Up",    yabaiCmd("-m window --swap north"))
    hs.hotkey.bind(hyperMod, "Down",  yabaiCmd("-m window --swap south"))

    -- fullscreen within the current space (mirrors $modifier+F,fullscreen)
    hs.hotkey.bind(hyperMod, "F", yabaiCmd("-m window --toggle zoom-fullscreen"))

    -- toggle split orientation (mirrors $modifier SHIFT+I,layoutmsg togglesplit)
    hs.hotkey.bind(hyperMod, "I", yabaiCmd("-m window --toggle split"))

    -- throw focused window to the next display
    hs.hotkey.bind(hyperMod, "N", yabaiCmd("-m window --display next --focus"))

    -- switch to space N (mirrors $modifier+1-9,workspace)
    -- send focused window to space N (mirrors $modifier SHIFT+1-9,movetoworkspace;
    -- uses alt+cmd instead of Hyper+shift since Hyper already bakes in shift)
    for i = 1, 9 do
      hs.hotkey.bind(hyperMod, tostring(i), yabaiCmd("-m space --focus " .. i))
      hs.hotkey.bind({ "alt", "cmd" }, tostring(i), yabaiCmd("-m window --space " .. i .. " --focus"))
    end

    -- keybind cheat sheet (mirrors $modifier+slash,exec list-keybinds)
    hs.hotkey.bind(hyperMod, "/", function()
      hs.alert.show(
        "hjkl focus | arrows move | f fullscreen | i split | n next display\n" ..
        "1-9 space | alt+cmd+1-9 send window to space",
        5
      )
    end)

    -- lock screen (mirrors $modifier+backspace,exec session menu)
    hs.hotkey.bind(hyperMod, "delete", hs.caffeinate.lockScreen)

    hs.alert.show("Hammerspoon config loaded")
  '';

  # Hammerspoon has no built-in "launch at login" that's manageable
  # declaratively (it's a GUI checkbox backed by a macOS Login Item), so
  # start it via a launchd agent instead — same pattern as yabai's agent
  # in modules/home/yabai.nix.
  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "Hammerspoon"
      ];
      RunAtLoad = true;
    };
  };
}
