{ pkgs, ... }:

{
  # ... your other config ...

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      color = "on";
      confirmation = "no";          # Don't ask for confirmation on destructive actions
      weekstart = "Monday";
      "color.active" = "rgb555";    # You can put keys with dots in quotes
    };
  };

  # ... the rest of your config ...
}
