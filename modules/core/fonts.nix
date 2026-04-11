{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  fonts = {
    packages = with pkgs; [
      cascadia-code
      fira-code
      dejavu_fonts
      corefonts
      vistafonts
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      jetbrains-mono
      material-icons
      maple-mono.NF
      minecraftia
      nerd-fonts.im-writing
      nerd-fonts.blex-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      symbola
      terminus_font
    ];
  };
}
