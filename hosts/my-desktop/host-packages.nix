{ pkgs, inputs, ... }: 

let
  # Define 'unstable' so we can use it below
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  environment.systemPackages = with pkgs; [
    audacity
    chromedriver
    discord
    nodejs
    gnumake42
    gnumake
    lua
    gcc
    neovide
    tree-sitter
    trash-cli 
    ghostscript 
    tectonic-unwrapped
    mermaid-cli 
    unstable.zotero
    python312
    uv
    figma-linux
    # figma-agent
    onlyoffice-documentserver
    onlyoffice-desktopeditors
    chromium
    ueberzugpp
    git-lfs
    zip
    quickemu
    opencode
    bun
    unstable.codex
    black
    ruff
    stylua
    unstable.antigravity-fhs
    lazygit
    hyprutils
    unstable.winboat
    obsidian
    poppler-utils
  ];

  fonts.fontDir.enable = true;
}
