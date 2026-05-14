{
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  settings = import ./yazi.nix;
  keymap = import ./keymap.nix;
  theme = import ./theme.nix;
  vfs = import ./vfs.nix;
  tomlFormat = pkgs.formats.toml { };
in
{
  programs.yazi = {
    enable = true;
    package = unstable.yazi;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
    settings = settings;
    keymap = keymap;
    theme = theme;
    plugins = {
      lazygit = unstable.yaziPlugins.lazygit;
      full-border = unstable.yaziPlugins.full-border;
      git = unstable.yaziPlugins.git;
      smart-enter = unstable.yaziPlugins.smart-enter;
    };

    initLua = ''
      require("full-border"):setup()
         require("git"):setup()
         require("smart-enter"):setup {
           open_multi = true,
         }
    '';
  };

  xdg.configFile."yazi/vfs.toml".source = tomlFormat.generate "yazi-vfs.toml" vfs;
}
