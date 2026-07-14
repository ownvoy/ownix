{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix)
    alacrittyEnable
    ghosttyEnable
    tmuxEnable
    waybarChoice
    weztermEnable
    vscodeEnable
    helixEnable
    doomEmacsEnable
    ;
in
{
  imports = [
    ./amfora.nix
    ./agenix.nix
    ./bash.nix
    ./bashrc-personal.nix
    ./bat.nix
    ./btop.nix
    ./bottom.nix
    ./cava.nix
    ./claude-code.nix
    ./codex.nix
    ./emoji.nix
    ./eza.nix
    ./fastfetch
    ./fzf.nix
    # ./figma.nix
    ./gh.nix
    ./git.nix
    ./gtk.nix
    ./huggingface.nix
    ./htop.nix
    ./hyprland
    ./innorix.nix
    ./kitty.nix
    ./lazygit.nix
    ./obs-studio.nix
    ./open-design.nix
    ./papers.nix
    ./pi.nix
    ./zotero.nix
    ./ssh.nix
    ./steam-compat.nix
    # ./nvf.nix
    ./neovim.nix
    ./noctalia
    # ./imagemagick.nix
    ./fctix.nix
    ./obs-studio.nix
    ./rofi
    ./qt.nix
    ./scripts
    ./scripts/gemini-cli.nix
    #./starship.nix
    #./starship-ddubs-1.nix
    ./taskwarrior.nix
    ./stylix.nix
    ./swappy.nix
    ./swaync.nix
    ./tealdeer.nix
    ./virtmanager.nix
    waybarChoice
    ./winboat.nix
    ./wlogout
    ./xdg.nix
    ./yazi
    ./zoxide.nix
    ./zsh
  ]
  ++ (if helixEnable then [ ./evil-helix.nix ] else [ ])
  ++ (if vscodeEnable then [ ./vscode.nix ] else [ ])
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
