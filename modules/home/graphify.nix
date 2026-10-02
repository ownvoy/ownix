# modules/home/graphify.nix
# Graphify (github:Graphify-Labs/graphify) — turns codebases/docs/PDFs into a
# queryable knowledge graph, used from Claude Code via the /graphify skill.
# The PyPI package `graphifyy` depends on ~30 pinned tree-sitter wheels that
# are not in nixpkgs, so instead of buildPythonPackage the CLI is a
# version-pinned uvx wrapper (uv resolves and caches the env on first run).
{ pkgs, ... }:
let
  version = "0.9.46";
  spec = "graphifyy[mcp,pdf,watch]==${version}";

  graphify = pkgs.writeShellScriptBin "graphify" ''
    exec ${pkgs.uv}/bin/uvx --from "${spec}" graphify "$@"
  '';

  # The skill drives graphify as a Python *library* (`from graphify... import`),
  # so it needs a python that can import it — not just the CLI wrapper.
  graphifyPython = pkgs.writeShellScriptBin "graphify-python" ''
    exec ${pkgs.uv}/bin/uv run --no-project --with "${spec}" python "$@"
  '';

  # Claude Code skill, pinned to the same era as the CLI version above.
  # Normally installed imperatively by `graphify install`; managed here instead.
  skillUpstream = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Graphify-Labs/graphify/91f4d120b630ee35c79bf3c75ccd186870a808f9/skills/graphify/skill.md";
    sha256 = "1lx2vb71r1nisan7gi60f7qdddz8k4byvcyl2713c85r4hvphf7i";
  };

  # Upstream assumes a mutable system python (`pip install --break-system-packages`).
  # Route every inline `python3 -c` through graphify-python instead, and drop
  # the pip self-install step entirely.
  skill = pkgs.runCommand "graphify-SKILL.md" { } ''
    sed -e 's#^python3 -c "import graphify".*#graphify-python -c "import graphify"#' \
        -e 's#python3 -c#graphify-python -c#g' \
        -e 's#python3 -m graphify#graphify-python -m graphify#g' \
        -e 's#"command": "python3"#"command": "graphify-python"#' \
        ${skillUpstream} > $out
    if grep -q -e "pip install" -e python3 $out; then
      echo "SKILL.md still references pip/python3 — patch needs updating" >&2
      exit 1
    fi
  '';
in
{
  home.packages = [
    graphify
    graphifyPython
  ];

  home.file.".claude/skills/graphify/SKILL.md".source = skill;
}
