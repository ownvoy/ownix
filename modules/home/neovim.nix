{ lib, pkgs, ... }:
let
  nvimConfigRepo = "https://github.com/ownvoy/nvim.git";
  linuxClipboardPackages = with pkgs; [
    wl-clipboard
    xsel
  ];
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    extraLuaPackages = ps: [ ps.magick ];
    # home-manager owns ~/.config/nvim/init.lua (it wires up the lua paths for the
    # magick luarock + node/python/ruby providers). Append the LazyVim bootstrap so
    # it also loads our GitHub-managed config in ~/.config/nvim/lua/ — otherwise HM's
    # init.lua shadows the repo's own init.lua and no plugins load.
    extraLuaConfig = ''
      require("config.lazy")
    '';
    # This ensures dependencies needed by LazyVim are available in the path
    extraPackages = with pkgs; [
      # LazyVim build dependencies
      gcc
      git
      gnumake
      unzip
      ripgrep
      fd
      imagemagick
      ueberzugpp
    ] ++ lib.optionals pkgs.stdenv.isLinux linuxClipboardPackages;
  };

  home.activation.linkNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"
    nvim_config="$HOME/.config/nvim"
    nvim_repo="${nvimConfigRepo}"

    if [ -L "$nvim_config" ]; then
      old_target="$(readlink "$nvim_config")"
      tmp_dir="$(mktemp -d "$HOME/.config/nvim.migrate.XXXXXX")"
      cp -R "$old_target"/. "$tmp_dir"/
      rm "$nvim_config"
      mv "$tmp_dir" "$nvim_config"
    fi

    if [ ! -e "$nvim_config" ]; then
      ${pkgs.git}/bin/git clone "$nvim_repo" "$nvim_config"
    elif [ -d "$nvim_config/.git" ]; then
      current_remote="$(${pkgs.git}/bin/git -C "$nvim_config" remote get-url origin 2>/dev/null || true)"
      if [ "$current_remote" = "$nvim_repo" ]; then
        if ${pkgs.git}/bin/git -C "$nvim_config" diff --quiet \
          && ${pkgs.git}/bin/git -C "$nvim_config" diff --cached --quiet; then
          ${pkgs.git}/bin/git -C "$nvim_config" pull --ff-only
        else
          echo "Skipping nvim config update because $nvim_config has local changes."
        fi
      else
        backup="$nvim_config.before-ownix-$(date +%Y%m%d%H%M%S)"
        mv "$nvim_config" "$backup"
        ${pkgs.git}/bin/git clone "$nvim_repo" "$nvim_config"
        echo "Moved existing nvim config with different origin to $backup"
      fi
    else
      backup="$nvim_config.before-ownix-$(date +%Y%m%d%H%M%S)"
      mv "$nvim_config" "$backup"
      ${pkgs.git}/bin/git clone "$nvim_repo" "$nvim_config"
      echo "Moved existing non-git nvim config to $backup"
    fi
  '';
}
