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
  # Route interactive `claude` through opencodex (modules/home/opencodex.nix)
  # so /model can pick non-Anthropic models. opencodex only runs on my-desktop
  # (the Mac has no `ocx`); on darwin, Claude Code runs locally on the Mac's
  # files and talks to my-desktop's proxy through the ocx-tunnel-my-desktop
  # launchd tunnel (modules/home/paseo-darwin.nix). The env mirrors what
  # `ocx claude` exports there (no ANTHROPIC_AUTH_TOKEN: claude.ai login stays).
  claudeAlias =
    if pkgs.stdenv.isDarwin then
      lib.concatStringsSep " " [
        "ANTHROPIC_BASE_URL=http://127.0.0.1:10100"
        "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1"
        "CLAUDE_CODE_AUTO_COMPACT_WINDOW=829800"
        "ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-5-5[1m]'"
        "ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-5[1m]'"
        "ANTHROPIC_DEFAULT_FABLE_MODEL='claude-fable-5-1[1m]'"
        "claude"
      ]
    else
      "ocx claude";
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

      # Fix stray "66;53;45M"-style characters when moving the trackpad at the
      # shell prompt: a TUI (Claude Code, nvim, ...) that crashes without
      # disabling mouse reporting leaves the mode on, so tmux forwards mouse
      # events to zsh as text. Reset every mouse-tracking mode before each
      # prompt. These are control sequences with no visible output, so they
      # don't disturb powerlevel10k's instant prompt.
      autoload -Uz add-zsh-hook
      _reset_mouse_reporting() {
        printf '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1016l' >/dev/tty 2>/dev/null
      }
      add-zsh-hook precmd _reset_mouse_reporting
      ZSH_AUTOSUGGEST_STRATEGY=(history)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

      if [[ -n "''${SSH_TTY:-}" || ( -n "''${SSH_CONNECTION:-}" && -z "''${KITTY_WINDOW_ID:-}" ) ]]; then
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
      # See claudeAlias above. This is a shell alias, not a
      # PATH-level rename, on purpose: it only expands when you type `claude`
      # yourself, and is invisible to anything that spawns the `claude` binary
      # directly by name (Paseo's own provider override in
      # modules/core/paseo.nix does that already; `ocx claude` itself execs the
      # real `claude` binary under the hood) — so there's no recursion risk.
      claude = claudeAlias;
    } // rebuildAliases // guiAliases;
  };
}
