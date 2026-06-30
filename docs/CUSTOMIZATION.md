# Customization Guide

This file lists common changes and the source file that owns each change.

## Add Or Change Hosts

Edit `flake.nix`:

```nix
machines = {
  my-desktop = {
    profile = "amd";
  };
  acer-laptop = {
    profile = "intel";
  };
};
```

Then create or update `hosts/<host>/`.

Typical flow:

```sh
cp -r hosts/default hosts/<new-host>
nixos-generate-config --show-hardware-config > hosts/<new-host>/hardware.nix
```

Set the profile to one of the directories in `profiles/`: `amd`, `intel`,
`nvidia`, `nvidia-laptop`, or `vm`.

## Change Per-Host Options

Edit `hosts/<host>/variables.nix`.

Common options:

- `displayManager`: `sddm` or `tui`.
- `tmuxEnable`, `alacrittyEnable`, `weztermEnable`, `ghosttyEnable`,
  `vscodeEnable`, `helixEnable`, `doomEmacsEnable`: optional app modules.
- `desktopShell`: current shell selection, such as `noctalia`.
- `browser`: command used as the default browser.
- `terminal`: command used as the default terminal.
- `keyboardLayout` and `consoleKeyMap`: keyboard settings.
- `enableNFS`, `printEnable`, `thunarEnable`: service and file manager toggles.
- `stylixImage`: wallpaper and theme palette source.
- `waybarChoice`: selected Waybar module.
- `animChoice`: selected Hyprland animation module.

Changing `terminal` or `browser` usually does not install the program by itself.
Make sure the relevant package or module is enabled too.

## Add System Packages

Use `modules/core/packages.nix` for packages that should be available
system-wide.

Use `modules/core/user.nix` or Home Manager modules for packages that are only
needed by the user environment.

Use `hosts/<host>/host-packages.nix` for machine-specific packages.

## Add Home Manager Programs

For a new user program:

1. Add a module under `modules/home/<program>.nix`.
2. Import it from `modules/home/default.nix`.
3. If it should be optional, gate it with a variable from
   `hosts/<host>/variables.nix`.

Existing optional examples include `wezterm`, `ghostty`, `tmux`, `vscode`,
`evil-helix`, and Doom Emacs.

## Change Hyprland

Hyprland configuration is split under `modules/home/hyprland/`.

- `hyprland.nix`: main Hyprland settings.
- `binds.nix`: keybindings.
- `windowrules.nix`: window rules.
- `hypridle.nix`: idle behavior.
- `hyprlock.nix`: lock screen behavior.
- `animations-*.nix`: selectable animation presets.

Select the animation preset from `hosts/<host>/variables.nix` using
`animChoice`.

## Change Waybar

Waybar variants live in `modules/home/waybar/`.

Select one in `hosts/<host>/variables.nix`:

```nix
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
```

## Change Codex

Codex config is declared in `modules/home/codex.nix`.

This file owns:

- default model and reasoning effort.
- trusted Codex project paths.
- enabled Codex plugins.
- `ruflo` MCP server configuration.

Because Home Manager writes `~/.codex/config.toml` as a Nix store symlink,
Codex cannot persist UI preference changes to that file. Change the Nix module
and rebuild instead.

