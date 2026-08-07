{ username, ... }:
{
  # yabai's scripting addition (SA) has to be (re-)loaded with
  # `sudo yabai --load-sa` every time yabai starts (see the top of
  # ~/.yabairc in modules/home/yabai.nix) so it doesn't prompt for a
  # password on every login/reboot.
  #
  # This NOPASSWD rule is pinned to the currently-installed yabai binary's
  # sha256 (via `shasum -a 256 $(which yabai)`) rather than the bare path —
  # that's yabai's own documented, safer alternative to a blanket NOPASSWD:
  # if yabai gets upgraded via homebrew, the hash goes stale and this rule
  # simply stops matching (falls back to a password prompt) until the hash
  # below is updated to match the new binary.
  security.sudo.extraConfig = ''
    ${username} ALL=(root) NOPASSWD: sha256:372ad557a7c54a6199a78dcbcefe5b60fd0224e5c1f5139cfaed00dfdaa44501 /opt/homebrew/bin/yabai --load-sa
  '';
}
