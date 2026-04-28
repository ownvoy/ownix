{ pkgs, inputs, ... }:
let
  cavaBg = inputs.cava-bg.packages.${pkgs.system}.default;
in
{
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bar_spacing = 1;
        bar_width = 2;
        frame_rate = 60;
      };
      color = {
        #gradient = 1;
        #gradient_color_1 = "'#011f30'";
        #gradient_color_2 = "'#09465b'";
        #gradient_color_3 = "'#045a93'";
        #gradient_color_4 = "'#00aa00'";
        #gradient_color_5 = "'#ffff00'";
        #gradient_color_6 = "'#cc8033'";
        #gradient_color_7 = "'#aa0000'";
        #gradient_color_8 = "'#ff00ff'";
        # Old config
        #gradient = 1;
        #gradient_color_1 = "'#8bd5ca'";
        #gradient_color_2 = "'#91d7e3'";
        #gradient_color_3 = "'#7dc4e4'";
        #gradient_color_4 = "'#8aadf4'";
        #gradient_color_5 = "'#c6a0f6'";
        #gradient_color_6 = "'#f5bde6'";
        #gradient_color_7 = "'#ee99a0'";
        #gradient_color_8 = "'#ed8796'";
        # Dracula
        gradient = 1;
        gradient_color_1 = "'#8BE9FD'";
        gradient_color_2 = "'#9AEDFE'";
        gradient_color_3 = "'#CAA9FA'";
        gradient_color_4 = "'#BD93F9'";
        gradient_color_5 = "'#FF92D0'";
        gradient_color_6 = "'#FF79C6'";
        gradient_color_7 = "'#FF6E67'";
        gradient_color_8 = "'#FF5555'";
      };
    };
  };

  home.packages = [ cavaBg ];

  xdg.configFile."cava-bg/config.toml".text = ''
    [general]
    framerate = 60
    dynamic_colors = true
    corner_radius = 0.0
    disable_audio = false

    [general.background_color]
    hex = "#000000"
    alpha = 0.0

    [display]
    position = "Fill"
    anchor_top = true
    anchor_bottom = true
    anchor_left = true
    anchor_right = true
    width = 0
    height = 0
    margin_top = 0
    margin_bottom = 0
    margin_left = 0
    margin_right = 0
    layer = "Bottom"
    opacity = 1.0
    scale_with_resolution = false

    [audio]
    bar_count = 80
    bar_width = 6.0
    bar_spacing = 2.0
    gap = 0.1
    bar_alpha = 0.82
    height_scale = 0.35
    smoothing = 0.8
    max_bar_height = 180.0
    min_bar_height = 0.0
    bar_shape = "Rectangle"

    [audio.bar_color]
    hex = "#89dceb"
    alpha = 1.0

    [colors]
    use_gradient = false
    gradient_direction = "BottomToTop"
    palette = [[0.72, 0.59, 0.38, 1.0], [0.37, 0.53, 0.46, 1.0]]

    [parallax]
    enabled = false
    mode = "Hybrid"
    enable_3d_depth = false
    show_visualizer = true
    visualizer_as_parallax_layer = false
    visualizer_layer_index = 0
    layers = []

    [xray]
    images_dir = ""

    [wallpaper]
    auto_detect_wallpaper = true
    sync_interval_seconds = 5

    [xray_mask]
    intensity = 0.8
    gamma = 1.2
    opacity = 1.0
    blend_mode = "Normal"
    use_background = false

    [performance]
    vsync = true
    multi_threaded_decode = true

    [advanced]
    verbose_logging = false
    frame_rate_limit = 60
    layer_cache_size = 5
  '';
}
