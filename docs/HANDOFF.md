# Codex Handoff

This file is the repo-local state board for continuing work across Codex
sessions. Keep it short, factual, and easy to overwrite.

## Current Goal

- Improve maintainer/agent documentation for this NixOS/Home Manager flake.

## Current State

- Added maintainer docs under `docs/`.
- Removed the separate `docs/RUFLO.md` after deciding it was too much detail for
  this repo.
- Added this handoff workflow so future sessions can recover context without
  relying only on chat history.
- Restored root `AGENT.md` as a short entry point for tools that only scan the
  repository root.
- Strengthened root `AGENT.md` so agents should read `docs/AGENT.md`, read
  `docs/HANDOFF.md`, and run `git status --short` before repository changes.
- Decided not to use a path-based commit helper. Commit messages should be
  suggested by Codex after reviewing the actual diff.
- Decided that `ruflo` should be used implicitly in the background when it
  helps with memory, workflow, or task-state recall.
- Decided that end-of-session flow should include a short `ruflo` memory update
  when available.

## Recent Changes

- `docs/README.md`: documentation index.
- `docs/REPO_MAP.md`: repository structure and source-of-truth map.
- `docs/CUSTOMIZATION.md`: common settings and where to edit them.
- `docs/RUNBOOK.md`: rebuild, update, validation, and troubleshooting commands.
- `docs/AGENT.md`: agent working rules and handoff expectations.
- `docs/HANDOFF.md`: this session continuity file.
- `AGENT.md`: root entry point requiring agent guidance, handoff, and git
  status checks before repository changes.
- `docs/RUNBOOK.md`: documents the Codex-suggested commit workflow.

## Decisions

- Keep handoff state in the repo as the primary source.
- Use `ruflo` memory only as a secondary helper when available.
- Use `ruflo` opportunistically even without explicit user wording when it adds
  value, but do not let it override repo-local source of truth.
- End repository-changing work by updating this handoff file, checking
  `git status --short`, and, when available, writing a short `ownix handoff`
  summary to `ruflo` memory.
- Avoid a dedicated `RUFLO.md`; mention ruflo only where it directly affects
  repo configuration.
- End repository-changing work by updating this handoff file and checking
  `git status --short`.
- Do not auto-commit; the user commits manually after reviewing changes and
  usually after `fr` succeeds for Nix changes.
- When the user explicitly wants to commit, Codex should inspect status/diff,
  suggest a message, ask for confirmation, then run git add/commit/push.

## Validation

- Checked that `docs/RUFLO.md` references were removed.
- Reviewed the generated docs by reading them back.
- No Nix evaluation was run for the latest commit-workflow documentation change.

## Open Items

- Decide whether to keep the new docs as-is or merge any of them into the root
  README later.

## Next Session Checklist

- Run `git status --short`.
- Read this file before making follow-up edits.
- If continuing documentation work, update this file again before stopping.
- Before ending repository-changing work, update this file and run
  `git status --short`.
- If `ruflo` is available, search memory for `ownix handoff` on resume and
  record a short `ownix handoff` summary at the end of the task.

## Ruflo Handoff Template

Use a short memory note like this:

```text
ownix handoff
goal: ...
changed: ...
decision: ...
validation: ...
next: ...
```
