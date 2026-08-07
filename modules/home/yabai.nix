{ ... }:
{
  # yabai itself is installed via a homebrew formula (not cask — see the
  # koekeishiya/formulae tap in modules/darwin/homebrew.nix). It still needs
  # a one-time manual Accessibility permission grant (System Settings ->
  # Privacy & Security -> Accessibility -> add /opt/homebrew/bin/yabai).
  #
  # Runs with the scripting addition (SA) loaded, which requires SIP to be
  # partially disabled (one-time, manual, recovery-mode reboot — see
  # `csrutil enable --without debug --without fs --without nvram` in the
  # yabai wiki, plus `sudo nvram boot-args="-arm64e_preview_abi"` on Apple
  # Silicon) and `sudo yabai --load-sa` run once. `sudo yabai --load-sa`
  # below re-injects the SA on every yabai start; the matching
  # passwordless-sudo rule lives in modules/darwin/yabai.nix.
  home.file.".yabairc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh

      sudo yabai --load-sa

      yabai -m config layout               bsp
      yabai -m config window_placement     second_child
      yabai -m config window_gap           8
      yabai -m config top_padding          8
      yabai -m config bottom_padding       8
      yabai -m config left_padding         8
      yabai -m config right_padding        8
      yabai -m config auto_balance         off

      # Animated resize makes window content visibly reflow/squish mid-frame
      # (app relayouts at every intermediate size) -- disabling it snaps
      # windows instantly instead, which reads as far less janky in practice.
      yabai -m config window_animation_duration 0

      # alt+drag to move/resize windows with the mouse.
      yabai -m config mouse_modifier    alt
      yabai -m config mouse_action1     move
      yabai -m config mouse_action2     resize
      yabai -m config mouse_drop_action swap
    '';
  };

  # Run yabai as a per-user launchd agent instead of `yabai --start-service`
  # so the whole setup stays declarative (no imperative service-install step).
  launchd.agents.yabai = {
    enable = true;
    config = {
      ProgramArguments = [ "/opt/homebrew/bin/yabai" ];
      KeepAlive = true;
      RunAtLoad = true;
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/tmp/yabai.stdout.log";
      StandardErrorPath = "/tmp/yabai.stderr.log";
    };
  };
}
