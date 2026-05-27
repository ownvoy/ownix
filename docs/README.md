# ownix Documentation

This directory contains maintainer-oriented notes for this flake. The root
`README.md` and `FAQ.md` are user-facing installation and usage references;
these files explain how the repository is put together and where to make
changes.

## Files

- `AGENT.md`: rules for AI agents working in this repository.
- `REPO_MAP.md`: source-of-truth map for hosts, profiles, modules, and scripts.
- `CUSTOMIZATION.md`: common edits and the files that own each setting.
- `RUNBOOK.md`: rebuild, update, validation, and troubleshooting commands.
- `HANDOFF.md`: current work state for continuing across Codex sessions.

## Source Of Truth

For configuration questions, prefer declarative files in this repo over
generated files in `$HOME`. Many runtime files under `~/.config` and `~/.codex`
are Home Manager outputs or symlinks into `/nix/store`.
