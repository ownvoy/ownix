# Tmux is a terminal multiplexer that allows you to run multiple terminal sessions in a single window.
{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-Space";
    terminal = "kitty";
    keyMode = "vi";

    extraConfig = ''
              set-option -g status-position top
              set-option -g status-justify left
              set-option -g status-style "bg=#1d2021,fg=#ebdbb2"
              set-option -g status-left-length 24
              set-option -g status-right-length 48
              set-option -g status-left " tmux "
              set-option -g status-right " #{session_name}  %H:%M "

              set-window-option -g window-status-separator "  "
              set-window-option -g window-status-style "bg=#1d2021,fg=#83a598"
              set-window-option -g window-status-current-style "bg=#1d2021,fg=#fabd2f,bold"
              set-window-option -g window-status-format " #{window_index} #{window_name} "
              set-window-option -g window-status-current-format " (#{window_index}) #{window_name} "

              set-option -g pane-border-style "fg=#504945"
              set-option -g pane-active-border-style "fg=#fabd2f"
              set-option -g message-style "bg=#3c3836,fg=#ebdbb2"
              set-option -g message-command-style "bg=#3c3836,fg=#fabd2f,bold"

              #set -g default-terminal "screen-256color"
              set-option -g history-limit 5000
              unbind %
              unbind '"'

              bind-key h select-pane -L
              bind-key j select-pane -D
              bind-key k select-pane -U
              bind-key l select-pane -R

              set -gq allow-passthrough on
              bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt

              bind-key -n C-Tab next-window
              bind-key -n C-S-Tab previous-window
              bind-key -n M-Tab new-window


            # Start windows and panes index at 1, not 0.
            set -g base-index 1
            setw -g pane-base-index 1


            bind-key "|" split-window -h -c "#{pane_current_path}"
            bind-key "\\" split-window -fh -c "#{pane_current_path}"

            bind-key "-" split-window -v -c "#{pane_current_path}"
            bind-key "_" split-window -fv -c "#{pane_current_path}"

            bind -r C-j resize-pane -D 15
            bind -r C-k resize-pane -U 15
            bind -r C-h resize-pane -L 15
            bind -r C-l resize-pane -R 15

            # 'c' to new window
            bind-key  c new-window

            # 'n' next  window
            bind-key  n next-window

            # 'p' next  previous
            bind-key  n previous-window

            unbind r
            bind r source-file ~/.config/tmux/tmux.conf

            bind -r m resize-pane -Z

              bind-key  t clock-mode
              bind-key  q display-panes
              bind-key  u refresh-client
              bind-key  o select-pane -t :.+

              # Vim-like copy mode: prefix+[ -> v to select -> y to yank
              bind-key -T copy-mode-vi v send-keys -X begin-selection
              bind-key -T copy-mode-vi V send-keys -X select-line
              bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
              bind-key -T copy-mode-vi y send-keys -X copy-selection \; run-shell "tmux save-buffer - | ${pkgs.wl-clipboard}/bin/wl-copy" \; send-keys -X cancel
              bind-key -T copy-mode-vi Enter send-keys -X copy-selection \; run-shell "tmux save-buffer - | ${pkgs.wl-clipboard}/bin/wl-copy" \; send-keys -X cancel
              bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection \; run-shell "tmux save-buffer - | ${pkgs.wl-clipboard}/bin/wl-copy" \; send-keys -X cancel


      ##### Display Popups #####

      bind C-y display-popup \
        -d "#{pane_current_path}" \
        -w 80% \
        -h 80% \
        -E "lazygit"
      bind C-n display-popup -E 'bash -i -c "read -p \"Session name: \" name; tmux new-session -d -s \$name && tmux switch-client -t \$name"'
      bind C-j display-popup -E "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
      #bind C-p display-popup -E "ipython"
      #bind C-f display-popup \
       # -w 80% \
       # -h 80% \
       # -E 'rmpc'
      bind C-r display-popup \
        -d "#{pane_current_path}" \
        -w 90% \
        -h 90% \
        -E "yazi"
      bind C-z display-popup \
        -w 90% \
        -h 90% \
        -E 'nvim ~/ddubsos/flake.nix'
      #bind C-g display-popup -E "bash -i ~/.tmux/scripts/chat-popup.sh"
      bind C-t display-popup \
        -d "#{pane_current_path}" \
        -w 75% \
        -h 75% \
        -E "zsh"

      ##### Display Menu #####

      bind d display-menu -T "#[align=centre]Dotfiles" -x C -y C \
        "ZaneyOS flake.nix"        f  "display-popup -E 'nvim ~/zaneyos/flake.nix'" \
        "ZaneyOS packages"         p  "display-popup -E 'nvim ~/zaneyos/modules/core/packages.nix'" \
        "ZaneyOS keybinds"         k  "display-popup -E 'nvim ~/zaneyos/modules/home/hyprland/binds.nix'" \
        "ZaneyOS env variables"    e  "display-popup -E 'nvim ~/zaneyos/modules/home/hyprland/env.nix'" \
        "ZaneyOS windowrules"      w  "display-popup -E 'nvim ~/zaneyos/modules/home/hyprland/windowrules.nix'" \
        "Exit"              q  ""



    '';

    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.sensible
      tmuxPlugins.yank
    ];
  };
}
