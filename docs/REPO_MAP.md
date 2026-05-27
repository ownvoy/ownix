# Repository Map

`ownix` is a NixOS flake with host-specific machines, profile-level hardware
selection, shared NixOS modules, and shared Home Manager modules.

## Entry Point

- `flake.nix`
  - Pins the main inputs: `nixpkgs`, `home-manager`, `stylix`, `nix-flatpak`,
    `agenix`, `noctalia`, and related sources.
  - Sets the current username with `username = "ownvoy"`.
  - Registers machines in the `machines` attrset.
  - Builds `nixosConfigurations` by mapping each machine to `mkNixosConfig`.
  - Exposes the `ruflo` package as a `claude-flow` wrapper.

Current hosts:

- `my-desktop` uses the `amd` profile.
- `acer-laptop` uses the `intel` profile.

## Host Layer

Host-specific files live in `hosts/<host>/`.

- `default.nix`: imports host-local system configuration.
- `hardware.nix`: generated hardware configuration for that machine.
- `host-packages.nix`: host-only package additions.
- `variables.nix`: primary host customization file.

Most day-to-day machine preferences should be changed in
`hosts/<host>/variables.nix`, not in shared modules.

## Profile Layer

Profiles live in `profiles/` and select driver families plus shared imports.

- `profiles/amd/default.nix`: imports host, driver modules, core modules, and
  enables AMD GPU support.
- `profiles/intel/default.nix`: imports host, driver modules, core modules, and
  enables Intel GPU support.
- `profiles/nvidia/default.nix`: Nvidia desktop profile.
- `profiles/nvidia-laptop/default.nix`: Nvidia Prime laptop profile.
- `profiles/vm/default.nix`: virtual machine profile.

Use profiles for hardware class differences. Use hosts for machine-specific
settings.

## NixOS Modules

Shared system modules live in `modules/core/`.

Important files:

- `modules/core/default.nix`: imports all shared core modules.
- `modules/core/user.nix`: wires Home Manager into NixOS.
- `modules/core/packages.nix`: shared system packages.
- `modules/core/flatpak.nix`: Flatpak integration.
- `modules/core/nh.nix`: `nh` rebuild tooling.
- `modules/core/stylix.nix`: system theme integration.
- `modules/core/services.nix`: shared services.
- `modules/core/printing.nix`: printer support, controlled by host variables.
- `modules/core/nfs.nix`: NFS support, controlled by host variables.

Driver modules live in `modules/drivers/` and are enabled by profiles.

## Home Manager Modules

Shared user modules live in `modules/home/`.

Important files:

- `modules/home/default.nix`: imports Home Manager modules and conditionally
  includes optional programs based on host variables.
- `modules/home/hyprland/`: Hyprland config, binds, rules, idle/lock, and
  animation imports.
- `modules/home/waybar/`: selectable Waybar variants.
- `modules/home/noctalia/`: Noctalia shell configuration.
- `modules/home/scripts/`: custom helper scripts exposed as user commands.
- `modules/home/codex.nix`: Codex config, plugins, and MCP server wiring.
- `modules/home/zsh/default.nix`: default interactive shell aliases and setup.

## Custom Packages

Custom package definitions live in `pkgs/`.

- `pkgs/endcord.nix`: builds the Endcord package from the `endcord-src` input.

## Generated Or Runtime State

Do not treat these as authoring sources:

- `~/.config/*` files produced by Home Manager.
- `~/.codex/config.toml` when it is a symlink into `/nix/store`.
- Nix store paths under `/nix/store`.
- Hardware files copied from another host.

Trace generated files back to the Nix module that produced them before editing.

