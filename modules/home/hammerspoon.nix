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
    local appMods = {
      { "alt", "cmd" },
      { "cmd", "alt", "ctrl", "shift" }, -- Hyper key (Caps Lock)
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

    bindApp("R", hs.reload)

    -- Hyper (Caps Lock) + c/v/q -> clean cmd+c / cmd+v / cmd+q is handled
    -- directly in Karabiner-Elements (see modules/home/karabiner.nix), not
    -- here — Karabiner cleanly overrides the held modifiers per-event,
    -- while Hammerspoon's synthetic keystrokes let the extra ctrl/alt/shift
    -- from the still-held Caps Lock leak through to the target app.

    ------------------------------------------------------------------
    -- Window management (ctrl+alt+cmd+<key>)
    ------------------------------------------------------------------
    local wmMod = { "ctrl", "alt", "cmd" }

    local function move(x, y, w, h)
      return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        local f = win:screen():frame()
        win:setFrame({
          x = f.x + f.w * x,
          y = f.y + f.h * y,
          w = f.w * w,
          h = f.h * h,
        })
      end
    end

    -- halves / maximize / centered float
    hs.hotkey.bind(wmMod, "Left",  move(0,    0,    0.5, 1))
    hs.hotkey.bind(wmMod, "Right", move(0.5,  0,    0.5, 1))
    hs.hotkey.bind(wmMod, "Up",    move(0,    0,    1,   1))
    hs.hotkey.bind(wmMod, "Down",  move(0.15, 0.15, 0.7, 0.7))

    -- quarters, laid out spatially on the keyboard (u i / j k)
    hs.hotkey.bind(wmMod, "U", move(0,   0,   0.5, 0.5))
    hs.hotkey.bind(wmMod, "I", move(0.5, 0,   0.5, 0.5))
    hs.hotkey.bind(wmMod, "J", move(0,   0.5, 0.5, 0.5))
    hs.hotkey.bind(wmMod, "K", move(0.5, 0.5, 0.5, 0.5))

    -- throw focused window to the next display
    hs.hotkey.bind(wmMod, "N", function()
      local win = hs.window.focusedWindow()
      if win then win:moveToScreen(win:screen():next()) end
    end)

    hs.alert.show("Hammerspoon config loaded")
  '';
}
