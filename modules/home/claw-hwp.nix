# modules/home/claw-hwp.nix
# claw-hwp (github:DoHyun468/claw-hwp) — Claude Code skill for reading,
# creating, and editing Korean Hangul Word Processor documents (.hwp / .hwpx),
# built on the rhwp WebAssembly engine. No Hancom Office / LibreOffice needed.
#
# Upstream ships this as a Claude Code *plugin marketplace*, normally installed
# imperatively with `claude plugin marketplace add …`. The plugin's payload is
# just a single skill whose scripts vendor all of their JS/Python dependencies
# (scripts/vendor/{rhwp,fflate,cfb}), so instead we drop that skill straight
# into ~/.claude/skills — the same declarative pattern used for [[graphify]].
{ inputs, pkgs, ... }:

{
  # SKILL.md invokes `node scripts/*.js` and `python3 scripts/*.py`; both are
  # already on PATH system-wide, but declare node here so the skill's hard
  # dependency (Node.js 18+) travels with the module.
  home.packages = [ pkgs.nodejs ];

  # The skill's `name:` is "hwp", so Claude Code discovers it at skills/hwp.
  # Read-only store symlink is fine: nothing writes into the skill dir, and the
  # scripts' relative `./vendor/...` imports resolve next to the real files.
  home.file.".claude/skills/hwp".source =
    "${inputs.claw-hwp}/plugins/claw-hwp/skills/hwp";
}
