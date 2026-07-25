{ ... }:
{
  # Make CapsLock behave like the macOS Cmd / a Super-ish modifier, the
  # Linux counterpart to the Karabiner "Hyper key" setup on darwin
  # (see modules/home/karabiner.nix).
  #
  # keyd runs below the compositor (evdev level), so the shortcuts it emits
  # are seen by every application — that is what lets CapsLock+c / CapsLock+v
  # inject a *real* Ctrl+C / Ctrl+V that copy & paste inside any app. The
  # xkb `caps:super` option (modules/home/hyprland/hyprland.nix) cannot do
  # that; it only turns CapsLock into a Super modifier.
  #
  # Because keyd grabs the physical CapsLock, the `caps` layer must default
  # to Meta (`[caps:M]`) so that every key NOT listed below still fires the
  # existing Hyprland SUPER binds:
  #   CapsLock+q -> killactive, CapsLock+a -> launcher,
  #   CapsLock+g/d/t/y/o -> apps, CapsLock+1..9 -> workspaces,
  #   CapsLock+h/j/k/l + arrows -> move focus, ...
  # The explicitly mapped keys below are sent as-is (without the extra Meta),
  # giving clean macOS-Cmd-style editing shortcuts:
  #   CapsLock+c -> copy, +v -> paste, +x -> cut, +z -> undo.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "layer(caps)";
        };
        "caps:M" = {
          c = "C-c";
          v = "C-v";
          x = "C-x";
          z = "C-z";
          # CapsLock+d -> real Ctrl+D (EOF): closes the shell / terminal pane,
          # like pressing Ctrl+D. (Discord moved to CapsLock+m in the Hyprland
          # binds — see modules/home/hyprland/binds.nix.)
          d = "C-d";
          # CapsLock+space -> Ctrl+Space, the tmux prefix (modules/home/tmux.nix).
          # So CapsLock+space then c makes a new tmux window, etc.
          space = "C-space";
        };
      };
    };
  };
}
