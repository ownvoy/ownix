{ pkgs, ... }: {
  programs.btop = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux then
        pkgs.btop.override {
          rocmSupport = true;
          cudaSupport = true;
        }
      else
        pkgs.btop;
    settings = {
      vim_keys = true;
      rounded_corners = true;
      proc_tree = true;
      show_gpu_info = if pkgs.stdenv.isLinux then "on" else "off";
      show_uptime = true;
      show_coretemp = true;
      cpu_sensor = "auto";
      show_disks = true;
      only_physical = true;
      io_mode = true;
      io_graph_combined = false;
    };
  };
}
