{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix)
    alacrittyEnable
    ghosttyEnable
    tmuxEnable
    weztermEnable
    helixEnable
    doomEmacsEnable
    ;
in
{
  imports = [
    ./bashrc-personal.nix
    ./bat.nix
    ./btop.nix
    ./bottom.nix
    ./codex.nix
    ./darwin-commands.nix
    ./eza.nix
    ./fastfetch
    ./gh.nix
    ./git.nix
    ./htop.nix
    ./kitty.nix
    ./lazygit.nix
    ./neovim.nix
    ./ssh.nix
    ./tealdeer.nix
    ./vscode.nix
    ./yazi
    ./zoxide.nix
    ./zsh
  ]
  ++ (if helixEnable then [ ./evil-helix.nix ] else [ ])
  ++ (
    if doomEmacsEnable then
      [
        ./editors/doom-emacs-install.nix
        ./editors/doom-emacs.nix
      ]
    else
      [ ]
  )
  ++ (if weztermEnable then [ ./wezterm.nix ] else [ ])
  ++ (if ghosttyEnable then [ ./ghostty.nix ] else [ ])
  ++ (if tmuxEnable then [ ./tmux.nix ] else [ ])
  ++ (if alacrittyEnable then [ ./alacritty.nix ] else [ ]);
}
