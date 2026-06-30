# Runbook

Use this file for common maintenance commands.

## Rebuild

Preferred command from any directory:

```sh
zcli rebuild
```

Direct `nh` command:

```sh
nh os switch /home/ownvoy/ownix --hostname "$(hostname)"
```

Shell aliases from `modules/home/zsh/default.nix`:

```sh
fr
fu
```

- `fr`: rebuild current host.
- `fu`: update inputs and rebuild current host.

## Safer Rebuild

Preview:

```sh
zcli rebuild --dry
```

Ask before applying:

```sh
zcli rebuild --ask
```

Limit build parallelism:

```sh
zcli rebuild --cores 4
```

Set as next boot without switching the live system:

```sh
zcli rebuild-boot
```

## Update

Update flake inputs and rebuild:

```sh
zcli update
```

Direct alias:

```sh
fu
```

Review `flake.lock` after updates, especially when `nixpkgs`,
`home-manager`, `stylix`, `noctalia`, or `nix-flatpak` changes.

## Validate Before Committing

Useful checks:

```sh
nix flake check
```

```sh
nix fmt
```

```sh
zcli rebuild --dry
```

If a full check is too slow, at least inspect the edited files and run a dry
rebuild for the affected host.

## Commit And Push

The preferred workflow is manual approval with a Codex-suggested commit
message.

When the user asks to commit, Codex should:

1. Run `git status --short`.
2. Review the relevant diff.
3. Suggest a concise commit message.
4. Ask for confirmation before staging, committing, or pushing.
5. After confirmation, run `git add` for the intended files, `git commit`, and
   `git push`.

For Nix changes, the usual flow is to run `fr` successfully before committing.

## Host Registration

Add a host:

```sh
zcli add-host <hostname> <profile>
```

Update host/profile mapping:

```sh
zcli update-host <hostname> <profile>
```

Auto-detect current host where supported:

```sh
zcli update-host
```

## Cleanup

List generations:

```sh
zcli list-gens
```

Clean old generations:

```sh
zcli cleanup
```

Trim SSD filesystems:

```sh
zcli trim
```

## Diagnostics

Create a system report:

```sh
zcli diag
```

The report is written to `~/diag.txt`.

## Common Troubleshooting

If a generated config file is read-only, check whether it is a Home Manager
symlink into `/nix/store`:

```sh
ls -la ~/.config/<path>
```

If it is generated, edit the matching file in `modules/home/` or
`modules/core/` and rebuild.

If a program is selected as a default but does not launch, confirm both of
these:

- the command name is set in `hosts/<host>/variables.nix`.
- the package or Home Manager module that installs it is enabled.

If display behavior changes unexpectedly, check these files first:

- `hosts/<host>/variables.nix`
- `modules/home/hyprland/`
- `modules/home/noctalia/`
- selected `modules/home/waybar/waybar-*.nix`
- `modules/core/stylix.nix`
- `modules/home/stylix.nix`
