{ lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    extraLuaPackages = ps: [ ps.magick ];
    # This ensures dependencies needed by LazyVim are available in the path
    extraPackages = with pkgs; [
      # LazyVim build dependencies
      gcc
      gnumake
      unzip
      ripgrep
      fd
      imagemagick
      ueberzugpp
      # Clipboards
      wl-clipboard
      xsel
    ];
  };

  home.activation.linkNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"
    ln -sfnT "/home/ownvoy/dotfiles/nvim" "$HOME/.config/nvim"
  '';
}
