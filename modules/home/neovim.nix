{ lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    extraLuaPackages = ps: [ ps.magick ];
    # This ensures dependencies needed by LazyVim are available in the path
    extraPackages = with pkgs; [
      # LazyVim build dependencies
      gcc
      gnumake
      unzip
      ripgrep
      fd
      imagemagick
      ueberzugpp
      # Clipboards
      wl-clipboard
      xsel
    ];
  };

  home.activation.linkNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"

    if [ -L "$HOME/.config/nvim" ]; then
      old_target="$(readlink -f "$HOME/.config/nvim")"
      tmp_dir="$(mktemp -d "$HOME/.config/nvim.migrate.XXXXXX")"
      cp -aT "$old_target" "$tmp_dir"
      rm "$HOME/.config/nvim"
      mv "$tmp_dir" "$HOME/.config/nvim"
    elif [ ! -d "$HOME/.config/nvim" ]; then
      mkdir -p "$HOME/.config/nvim"
    fi

    rm -f "$HOME/.config/nvim/init.lua"
    printf '%s\n%s\n' \
      '-- bootstrap lazy.nvim, LazyVim and your plugins' \
      'require("config.lazy")' \
      > "$HOME/.config/nvim/init.lua"

    mkdir -p "$HOME/.config/nvim/lua/plugins"
    cat > "$HOME/.config/nvim/lua/plugins/neovide.lua" <<'EOF'
    return {
      {
        "LazyVim/LazyVim",
        opts = function()
          if not vim.g.neovide then
            return
          end

          local function sync_neovide_background()
            local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
            if not normal or not normal.bg then
              return
            end

            local opacity = vim.g.neovide_opacity or 1.0
            local alpha = math.max(0, math.min(255, math.floor(opacity * 255 + 0.5)))
            vim.g.neovide_background_color = string.format("#%06x%02x", normal.bg, alpha)
          end

          local group = vim.api.nvim_create_augroup("OwnixNeovideTheme", { clear = true })
          vim.api.nvim_create_autocmd("ColorScheme", {
            group = group,
            callback = sync_neovide_background,
          })
          vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            once = true,
            callback = function()
              vim.schedule(sync_neovide_background)
            end,
          })
        end,
      },
    }
    EOF
  '';
}
