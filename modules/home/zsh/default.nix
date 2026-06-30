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
      { }
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

      setopt append_history
      setopt inc_append_history
      setopt share_history
      setopt hist_ignore_all_dups
      setopt hist_reduce_blanks
      ZSH_AUTOSUGGEST_STRATEGY=(history)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

      if [[ -n "''${SSH_CONNECTION:-}" || -n "''${SSH_TTY:-}" ]]; then
        PROMPT='%n@%m:%~ %# '
        RPROMPT=
        unset RPS1
        unset ZLE_RPROMPT_INDENT
        POWERLEVEL9K_DISABLE_HOT_RELOAD=true
        ZSH_AUTOSUGGEST_STRATEGY=()
      fi

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
