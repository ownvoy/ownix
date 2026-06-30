{ host
, username
, pkgs
, lib
, ...
}:
let
  rebuildAliases =
    if pkgs.stdenv.isDarwin then
      {
        fr = "sudo darwin-rebuild switch --flake path:/Users/${username}/ownix#${host}";
        fu = "cd /Users/${username}/ownix && nix flake update && sudo darwin-rebuild switch --flake path:/Users/${username}/ownix#${host}";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      }
    else
      {
        fr = "nh os switch /home/${username}/ownix --hostname ${host}";
        fu = "nh os switch /home/${username}/ownix --hostname ${host} --update";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      };
  guiAliases =
    if pkgs.stdenv.isDarwin then
      {
        brave = "open -a 'Brave Browser'";
        chrome = "open -a 'Google Chrome'";
        discord = "open -a Discord";
        zotero = "open -a Zotero";
      }
    else
      { };
in
{
  imports = [
    ./zshrc-personal.nix
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" "pattern" "regexp" "root" "line" ];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
    ];

    initContent = ''
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi

      # Start a dedicated tmux session for each kitty-launched interactive shell.
      if [[ $- == *i* ]] && [ -n "$KITTY_WINDOW_ID" ] && [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
        session_name="kitty-''${KITTY_WINDOW_ID}-''${PPID}-$(date +%s)"
        exec tmux new-session -s "$session_name" -c "$PWD"
      fi
    '';

    shellAliases = {
      sv = "sudo nvim";
      v = "nvim";
      c = "clear";
      lzg = "lazygit";
      lzd = "lazydocker";
      zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/releases/latest/download/install-zaneyos.sh)";
      cat = "bat";
      man = "batman";
    } // rebuildAliases // guiAliases;
  };
}
