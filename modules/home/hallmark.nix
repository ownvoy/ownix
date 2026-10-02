# modules/home/hallmark.nix
# hallmark (github:Nutlope/hallmark) — Claude Code design skill that pushes
# generated UIs away from the LLM-default "AI slop" look: structural variety,
# typography/colour/spacing rules, plus audit/redesign/study verbs.
#
# Upstream is normally installed per-project by a skills manager (which writes
# skills-lock.json and a gitignored .agents/ copy). The skill is pure markdown
# with no runtime deps, so it is dropped straight into ~/.claude/skills instead
# — same declarative pattern as [[claw-hwp]] — making it available in every
# directory rather than only where it was installed.
{ inputs, ... }:

{
  home.file.".claude/skills/hallmark".source = "${inputs.hallmark}/skills/hallmark";
}
