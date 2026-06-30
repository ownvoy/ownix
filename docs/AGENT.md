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

- Read `docs/HANDOFF.md` early when continuing work from a previous session.
- `flake.nix` defines the main system entrypoints and host/profile wiring.
- `hosts/` contains host-specific machine configuration.
- `profiles/` contains profile-level imports and system composition.
- `modules/` contains reusable NixOS/Home Manager modules and most package/config declarations.
- Many files under `~/.config` are generated or symlinked outputs, not the authoring source.

## Ruflo Usage

- Do not wait for the user to explicitly say `ruflo` when its background use would materially help.
- Use available `ruflo` tools opportunistically for memory search, workflow recommendation, progress lookup, and task-state recall.
- Prefer repo-local files as the source of truth. Treat `ruflo` as a secondary helper for recall and coordination.
- Use `ruflo` especially when resuming work across sessions, when earlier decisions may matter, or when the next step is unclear from git diff and local files alone.
- Do not block straightforward repository work on `ruflo`. If local source is sufficient, proceed.

## Session Handoff

- Keep `docs/HANDOFF.md` short and current when work spans sessions.
- Update it after meaningful repository changes, before stopping with unfinished work, or when the next step would be hard to infer from git diff alone.
- Record only durable context: goal, changed files, decisions, validation, risks, and next actions.
- When possible, use this compact handoff structure: `goal`, `changed`, `decision`, `validation`, and `next`.
- Do not use handoff notes as a substitute for committing or checking `git status`.
- At the end of repository-changing work, update `docs/HANDOFF.md` and check `git status --short`.
- At the end of repository-changing work, if `ruflo` memory is available, record a short `ownix handoff` summary in the background.
- Keep `ruflo` handoff memory short. Prefer a few durable lines over a long narrative.
- Do not auto-commit. The user commits manually after reviewing changes and, for Nix changes, usually after a successful `fr`.
- If the user asks to commit, review `git status --short` and the relevant diff, suggest a commit message, then ask for confirmation before running `git add`, `git commit`, or `git push`.
- If `ruflo` memory is available, use it as a secondary recall layer for important decisions even when the user did not explicitly request it, but keep the repo-local handoff file as the primary source.

## Response Preference

- When asked "is this configured here?", answer from the declarative files and cite the relevant local file paths.
- If runtime inspection is still useful, clearly separate it from the declarative source, e.g. "declared here" vs. "materialized here".
