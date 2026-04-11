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
