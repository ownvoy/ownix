{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  zotmoovPkg =
    if pkgs ? zotmoov then
      pkgs.zotmoov
    else if unstable ? zotmoov then
      unstable.zotmoov
    else
      null;
  homeDir = config.home.homeDirectory;
  papersDir = "${homeDir}/Documents/Papers";
  papersStorageDir = "${papersDir}/storage";
  papersLinkedBaseDir = papersDir;
  zoteroDataDir =
    if pkgs.stdenv.isDarwin then
      "${homeDir}/Zotero"
    else
      "${homeDir}/.zotero/zotero";
  zotmoovBin =
    if zotmoovPkg != null then
      "${zotmoovPkg}/bin/zotmoov"
    else
      "zotmoov";
in
{
  warnings = lib.optionals (zotmoovPkg == null) [
    "ownix Papers module: zotmoov package was not found in nixpkgs or nixpkgs-unstable. The declarative scaffold is installed, but you will need to package/install zotmoov separately before using zotmoov-sync."
  ];

  home.packages =
    [
      pkgs.git
      pkgs.git-lfs
    ]
    ++ lib.optionals (zotmoovPkg != null) [ zotmoovPkg ];

  home.sessionVariables = {
    PAPERS_REPO_DIR = papersDir;
    ZOTERO_DATA_DIR = zoteroDataDir;
    ZOTERO_LINKED_ATTACHMENT_BASE_DIR = papersLinkedBaseDir;
    ZOTMOOV_CONFIG = "${config.xdg.configHome}/zotmoov/config.toml";
  };

  home.shellAliases = {
    papers = "cd \"$PAPERS_REPO_DIR\"";
    zotmoov-sync = "${zotmoovBin} sync --config \"$ZOTMOOV_CONFIG\"";
  };

  xdg.configFile."zotmoov/config.toml".text = ''
    # ownix-managed zotmoov scaffold
    # Adjust key names if your zotmoov build expects a different schema.
    # The important part is that all paths stay declared here.

    papers_dir = "${papersDir}"
    storage_dir = "${papersStorageDir}"
    zotero_data_dir = "${zoteroDataDir}"

    # Recommended Zotero-side settings:
    # - Linked Attachment Base Directory: ${papersLinkedBaseDir}
    # - Better BibTeX auto-export target: ${papersDir}/library.bib
  '';

  home.activation.clonePapersRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    papers_dir="${papersDir}"
    repo_slug="ownvoy/Papers"
    repo_url="git@github.com:ownvoy/Papers.git"
    repo_url_https="https://github.com/ownvoy/Papers.git"

    clone_papers_repo() {
      if command -v gh >/dev/null 2>&1; then
        gh repo clone "$repo_slug" "$papers_dir" && return 0
      fi

      ${pkgs.git}/bin/git clone "$repo_url" "$papers_dir" && return 0
      ${pkgs.git}/bin/git clone "$repo_url_https" "$papers_dir" && return 0
      return 1
    }

    mkdir -p "$(dirname "$papers_dir")"

    if [ ! -e "$papers_dir" ]; then
      if ! clone_papers_repo; then
        echo "Skipping Papers clone; make sure GitHub access is configured for $repo_slug"
      fi
    elif [ -d "$papers_dir/.git" ]; then
      current_remote="$(${pkgs.git}/bin/git -C "$papers_dir" remote get-url origin 2>/dev/null || true)"
      if [ "$current_remote" != "$repo_url" ] && [ "$current_remote" != "$repo_url_https" ]; then
        echo "Papers repo exists at $papers_dir but origin is $current_remote"
      fi
    elif [ -d "$papers_dir/storage" ] \
      && [ -z "$(find "$papers_dir/storage" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ] \
      && [ "$(find "$papers_dir" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" = "1" ]; then
      rm -rf "$papers_dir"
      if ! clone_papers_repo; then
        mkdir -p "$papers_dir"
        echo "Skipping Papers clone; make sure GitHub access is configured for $repo_slug"
      fi
    elif [ -z "$(find "$papers_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
      rmdir "$papers_dir"
      if ! clone_papers_repo; then
        mkdir -p "$papers_dir"
        echo "Skipping Papers clone; make sure GitHub access is configured for $repo_slug"
      fi
    else
      echo "Skipping Papers clone because $papers_dir already exists and is not a git repository."
    fi

    mkdir -p "${papersStorageDir}"
  '';

  home.activation.pullPapersLfs = lib.hm.dag.entryAfter [ "installPackages" ] ''
    papers_dir="${papersDir}"
    repo_slug="ownvoy/Papers"
    export PATH="${pkgs.git}/bin:${pkgs.git-lfs}/bin:$PATH"

    if [ -d "$papers_dir/.git" ] && [ -f "$papers_dir/.gitattributes" ]; then
      if grep -q 'filter=lfs' "$papers_dir/.gitattributes"; then
        (
          cd "$papers_dir"
          ${pkgs.git-lfs}/bin/git-lfs install --local
          ${pkgs.git-lfs}/bin/git-lfs pull --include="*.pdf" --exclude=""
        ) || \
          echo "Skipping git-lfs pull for $repo_slug"
      fi
    fi
  '';
}
