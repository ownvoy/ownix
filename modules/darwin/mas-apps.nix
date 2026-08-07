{ lib, username, ... }:
let
  # Mac App Store apps, keyed by the .app bundle name used to detect an
  # existing install. Requires ${username} to be signed in to the App Store.
  #
  # homebrew.masApps can't be used here: mas 7 escalates to root via sudo
  # internally, which fails without a password when brew bundle runs as
  # ${username} during activation. Activation itself already runs as root, so
  # run mas here with the env vars a `sudo mas` invocation would carry
  # (SUDO_UID/SUDO_GID for dropping privileges, HOME kept by macOS sudo).
  apps = {
    "KakaoTalk.app" = {
      name = "KakaoTalk";
      id = 869223134;
    };
  };
  mas = "/opt/homebrew/bin/mas";
in
{
  system.activationScripts.postActivation.text = lib.mkAfter (
    lib.concatStrings (
      lib.mapAttrsToList (bundle: app: ''
        if [ ! -e "/Applications/${bundle}" ]; then
          echo "installing ${app.name} from the Mac App Store..." >&2
          SUDO_UID="$(id -u ${username})" SUDO_GID="$(id -g ${username})" \
            HOME="/Users/${username}" \
            ${mas} get ${toString app.id} \
            || echo "warning: failed to install ${app.name}; is ${username} signed in to the App Store?" >&2
        fi
      '') apps
    )
  );
}
