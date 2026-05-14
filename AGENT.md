# AGENT.md

This repository is a declarative NixOS/Home Manager configuration.

## Working Rules

- Treat questions about whether something is "configured", "installed", "enabled", or "mapped" as questions about the declarative source in this repo first.
- Search local source before using the web. In most cases, inspect `flake.nix`, `hosts/`, `profiles/`, `modules/`, and related repo files before checking runtime docs.
- Prefer the source of truth over generated state. If `~/.config/...` is a symlink into the Nix store, trace it back to the Home Manager or Nix module that produced it.
- Do not answer config questions from upstream defaults when the repo may override them. Check the local declarations first, then mention upstream defaults only as secondary context.
- For installation questions, determine whether the package/program is declared in Nix files before discussing manual installation steps.
- For keybindings, options, and app behavior, inspect local config files and module definitions before assuming defaults from official documentation.
- Use web search only when local source is insufficient, or when the user explicitly asks for upstream/current external information.

## Repo-Specific Guidance

- `flake.nix` defines the main system entrypoints and host/profile wiring.
- `hosts/` contains host-specific machine configuration.
- `profiles/` contains profile-level imports and system composition.
- `modules/` contains reusable NixOS/Home Manager modules and most package/config declarations.
- Many files under `~/.config` are generated or symlinked outputs, not the authoring source.

## Response Preference

- When asked "is this configured here?", answer from the declarative files and cite the relevant local file paths.
- If runtime inspection is still useful, clearly separate it from the declarative source, e.g. "declared here" vs. "materialized here".
