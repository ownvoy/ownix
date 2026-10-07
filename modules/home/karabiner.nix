{ ... }:
let
  hyperMods = [
    "left_command"
    "left_control"
    "left_option"
    "left_shift"
  ];

  # Hyper+<key> -> a clean <mods>+<toKey>. Done in Karabiner rather than
  # Hammerspoon: Karabiner's `to.modifiers` temporarily overrides the
  # currently-held modifiers (releasing ctrl/alt/shift for just this event,
  # then restoring them) so the target app sees a real, uncontaminated
  # shortcut even while Caps Lock is still physically held down. Hammerspoon
  # synthesizing the same keystroke via hs.eventtap doesn't get that
  # override/restore behavior, so the extra modifiers leak through.
  hyperTo =
    fromKey: toKey: toMods:
    {
      type = "basic";
      from = {
        key_code = fromKey;
        modifiers = {
          mandatory = hyperMods;
        };
      };
      to = [
        {
          key_code = toKey;
          modifiers = toMods;
        }
      ];
    };

  cleanCmd = key: hyperTo key key [ "left_command" ];

  # Every other letter: Caps Lock also works as a plain Control key, so
  # e.g. readline/emacs/tmux ctrl+<letter> shortcuts work through it too.
  # Excludes the letters already claimed above (c/v/q/a/e), the ones
  # Hammerspoon's app launcher owns (g/m/t/y/o), the ones its yabai-backed
  # window management owns (h/j/k/l/f/i/n), and hs.reload (r) — see
  # modules/home/hammerspoon.nix.
  claimedLetters = [
    "c"
    "v"
    "q"
    "a"
    "e"
    "g"
    "m"
    "t"
    "y"
    "o"
    "h"
    "j"
    "k"
    "l"
    "f"
    "i"
    "n"
    "r"
  ];
  allLetters = [
    "a"
    "b"
    "c"
    "d"
    "e"
    "f"
    "g"
    "h"
    "i"
    "j"
    "k"
    "l"
    "m"
    "n"
    "o"
    "p"
    "q"
    "r"
    "s"
    "t"
    "u"
    "v"
    "w"
    "x"
    "y"
    "z"
  ];
  ctrlLetters = builtins.filter (k: !(builtins.elem k claimedLetters)) allLetters;
  cleanCtrl = key: hyperTo key key [ "left_control" ];

  # Caps Lock held -> Hyper; tapped alone -> `aloneKey`.
  capsLockHyper = aloneKey: {
    type = "basic";
    from = {
      key_code = "caps_lock";
      modifiers = {
        optional = [ "any" ];
      };
    };
    to = [
      {
        key_code = "left_shift";
        modifiers = [
          "left_command"
          "left_control"
          "left_option"
        ];
      }
    ];
    to_if_alone = [ aloneKey ];
  };
in
{
  # Karabiner-Elements itself is installed via the "karabiner-elements"
  # homebrew cask (see modules/darwin/homebrew.nix) — it needs a system
  # extension approval that can't be scripted through nix.
  #
  # We only ever write into ~/.config/karabiner/assets/complex_modifications/,
  # which is a library of *importable* rule definitions — Karabiner never
  # rewrites files in that directory, unlike the top-level karabiner.json
  # (which holds live app state: connected devices, enabled profiles, etc).
  # That keeps this declarative without fighting the GUI over ownership of
  # its own state file. The rules still need a one-time manual "Enable" in
  # Karabiner-Elements > Complex Modifications > Add rule.
  home.file.".config/karabiner/assets/complex_modifications/hyper_key.json".text =
    builtins.toJSON {
      title = "Hyper Key (Caps Lock)";
      rules = [
        {
          description = "Caps Lock held with another key -> Hyper (^⌥⇧⌘); tapped alone -> real Caps Lock (keeps 한/영 toggle working; fn/🌐 in Spotlight)";
          manipulators = [
            # Spotlight's search field is an overlay that never becomes the
            # frontmost app, and the Caps Lock 한/영 toggle doesn't reliably
            # reach it. The Globe (fn) key does — it's handled by the
            # system-wide TextInputSwitcher — so tap fn there instead. Relies
            # on "Press 🌐 key to: Change Input Source", and on
            # Karabiner-Elements >= 16.0, which detects overlay windows like
            # Spotlight as frontmost. Keep it first: first match wins.
            (
              capsLockHyper { apple_vendor_top_case_key_code = "keyboard_fn"; }
              // {
                conditions = [
                  {
                    type = "frontmost_application_if";
                    bundle_identifiers = [ "^com\\.apple\\.Spotlight$" ];
                  }
                ];
              }
            )
            # Pass the real caps_lock key event through untouched on a lone
            # tap, instead of remapping it — this is what lets whatever
            # macOS/keyboard already binds to a caps-lock tap (e.g. the
            # 한/영 input-source toggle on Korean keyboards) keep working.
            (capsLockHyper { key_code = "caps_lock"; })
          ];
        }
        {
          description = "Hyper (Caps Lock) + c/v/q -> clean cmd+c / cmd+v / cmd+q";
          manipulators = map cleanCmd [
            "c"
            "v"
            "q"
          ];
        }
        {
          description = "Hyper (Caps Lock) + a -> Spotlight (cmd+space)";
          manipulators = [
            (hyperTo "a" "spacebar" [ "left_command" ])
          ];
        }
        {
          description = "Hyper (Caps Lock) + e -> Emoji & Symbols picker (cmd+ctrl+space)";
          manipulators = [
            (hyperTo "e" "spacebar" [ "left_command" "left_control" ])
          ];
        }
        {
          description = "Hyper (Caps Lock) + Space -> tmux prefix (ctrl+g)";
          manipulators = [
            (hyperTo "spacebar" "g" [ "left_control" ])
          ];
        }
        {
          description = "Hyper (Caps Lock) + any other letter -> clean ctrl+<letter> (Caps Lock as Control)";
          manipulators = map cleanCtrl ctrlLetters;
        }
      ];
    };
}
