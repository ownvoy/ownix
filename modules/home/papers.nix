{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  papersDir = "${homeDir}/Documents/Papers";
  papersStorageDir = "${papersDir}/storage";
  papersLinkedBaseDir = papersDir;
  zoteroDataDir =
    if pkgs.stdenv.isDarwin then
      "${homeDir}/Zotero"
    else
      "${homeDir}/.zotero/zotero";
  zoteroStorageDir = "${zoteroDataDir}/storage";
  syncZoteroPapers = pkgs.writeShellApplication {
    name = "sync-zotero-papers";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
    ];
    text = ''
      set -eu

      papers_dir="${papersDir}"
      zotero_storage_dir="${zoteroStorageDir}"

      mkdir -p "$papers_dir"

      if [ ! -d "$zotero_storage_dir" ]; then
        exit 0
      fi

      find "$zotero_storage_dir" -mindepth 2 -maxdepth 2 \( -type f -o -type l \) -name '*.pdf' | while read -r src; do
        if [ -L "$src" ]; then
          continue
        fi

        key="$(basename "$(dirname "$src")")"
        base="$(basename "$src")"
        dest="$papers_dir/$base"

        if [ ! -e "$dest" ]; then
          mv "$src" "$dest"
          ln -s "$dest" "$src"
          continue
        fi

        if cmp -s "$src" "$dest"; then
          rm -f "$src"
          ln -s "$dest" "$src"
          continue
        fi

        stem="''${base%.pdf}"
        alt_dest="$papers_dir/$stem [$key].pdf"

        if [ ! -e "$alt_dest" ]; then
          mv "$src" "$alt_dest"
          ln -s "$alt_dest" "$src"
          continue
        fi

        if cmp -s "$src" "$alt_dest"; then
          rm -f "$src"
          ln -s "$alt_dest" "$src"
          continue
        fi

        conflict_dest="$papers_dir/$stem [$key]-conflict.pdf"
        mv "$src" "$conflict_dest"
        ln -s "$conflict_dest" "$src"
      done
    '';
  };
  syncLaunchAgentLabel = "com.ownix.sync-zotero-papers";
in
{
  home.packages =
    [
      pkgs.git
      pkgs.git-lfs
      syncZoteroPapers
    ];

  home.sessionVariables = {
    PAPERS_REPO_DIR = papersDir;
    ZOTERO_DATA_DIR = zoteroDataDir;
    ZOTERO_LINKED_ATTACHMENT_BASE_DIR = papersLinkedBaseDir;
  };

  home.shellAliases = {
    papers = "cd \"$PAPERS_REPO_DIR\"";
    papers-sync = "${syncZoteroPapers}/bin/sync-zotero-papers";
  };

  home.file."Library/LaunchAgents/${syncLaunchAgentLabel}.plist" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>${syncLaunchAgentLabel}</string>
          <key>ProgramArguments</key>
          <array>
            <string>${syncZoteroPapers}/bin/sync-zotero-papers</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>StartInterval</key>
          <integer>300</integer>
          <key>StandardOutPath</key>
          <string>${homeDir}/Library/Logs/${syncLaunchAgentLabel}.log</string>
          <key>StandardErrorPath</key>
          <string>${homeDir}/Library/Logs/${syncLaunchAgentLabel}.log</string>
        </dict>
      </plist>
    '';
  };

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

  home.activation.loadPapersSyncAgent = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      agent_plist="${homeDir}/Library/LaunchAgents/${syncLaunchAgentLabel}.plist"

      /bin/launchctl unload "$agent_plist" >/dev/null 2>&1 || true
      /bin/launchctl load -w "$agent_plist" >/dev/null 2>&1 || true
      ${syncZoteroPapers}/bin/sync-zotero-papers || true
    ''
  );
}
