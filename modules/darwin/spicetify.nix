{ inputs, username, ... }:
{
  # Spiced Spotify lands in environment.systemPackages, so the existing
  # activation script in default.nix copies Spotify.app into /Applications.
  # Theme/scheme and the spicetify-cli fix live in ../spicetify.nix, shared
  # with the NixOS hosts.
  imports = [
    inputs.spicetify-nix.darwinModules.spicetify
    ../spicetify.nix
  ];

  # Spotify's auto-updater (running as ${username}) stages downloads in
  # PersistentCache/Update and then swaps out /Applications/Spotify.app,
  # replacing the spiced build with a stock one. Pin that dir as an empty,
  # root-owned, immutable directory so staging always fails: uchg can only
  # be cleared by the owner (root), so the user-level updater can neither
  # write into it nor delete/recreate it.
  system.activationScripts.extraActivation.text = ''
    echo "blocking Spotify auto-updates for ${username}..." >&2
    spotify_cache="/Users/${username}/Library/Application Support/Spotify/PersistentCache"
    if [ ! -d "$spotify_cache" ]; then
      /usr/bin/install -d -o ${username} -g staff \
        "/Users/${username}/Library/Application Support/Spotify" "$spotify_cache"
    fi
    /usr/bin/chflags nouchg "$spotify_cache/Update" 2>/dev/null || true
    rm -rf "$spotify_cache/Update"
    /bin/mkdir "$spotify_cache/Update"
    /bin/chmod 555 "$spotify_cache/Update"
    /usr/bin/chflags uchg "$spotify_cache/Update"
  '';
}
