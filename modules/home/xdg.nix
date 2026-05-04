{ ... }: {
  xdg = {
    enable = true;
    # Desktop apps frequently rewrite ~/.config/mimeapps.list.
    # When Home Manager owns that file, those rewrites break future activations.
    # Leave MIME associations unmanaged until we explicitly define them in Nix.
    mime.enable = false;
    mimeApps.enable = false;
    # portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    #   configPackages = [ pkgs.hyprland ];
    # };
  };
}
