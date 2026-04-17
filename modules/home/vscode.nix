{ lib, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        userSettings = {
          "window.autoDetectColorScheme" = false;
          "workbench.preferredDarkColorTheme" = lib.mkForce "Default Dark Modern";
          "workbench.colorTheme" = lib.mkForce "Default Dark Modern";
          "editor.cursorBlinking" = "solid";
          "workbench.colorCustomizations" = {
            "editor.background" = "#111317";
            "editor.foreground" = "#E7E1D7";
            "editorLineNumber.foreground" = "#6F7782";
            "editorLineNumber.activeForeground" = "#D9B67A";
            "editorCursor.foreground" = "#C6A36A";
            "editor.selectionBackground" = "#2A303980";
            "editor.inactiveSelectionBackground" = "#252A3360";
            "editorIndentGuide.background1" = "#2A3039";
            "editorIndentGuide.activeBackground1" = "#6F7782";
            "sideBar.background" = "#16181D";
            "sideBar.foreground" = "#E7E1D7";
            "activityBar.background" = "#16181D";
            "activityBar.foreground" = "#D9B67A";
            "activityBar.activeBorder" = "#C6A36A";
            "titleBar.activeBackground" = "#16181D";
            "titleBar.activeForeground" = "#E7E1D7";
            "statusBar.background" = "#16181D";
            "statusBar.foreground" = "#E7E1D7";
            "statusBar.debuggingBackground" = "#C6A36A";
            "statusBar.debuggingForeground" = "#101114";
            "tab.activeBackground" = "#1D2128";
            "tab.activeForeground" = "#E7E1D7";
            "tab.inactiveBackground" = "#16181D";
            "tab.inactiveForeground" = "#A9B0BB";
            "tab.activeBorderTop" = "#C6A36A";
            "panel.background" = "#111317";
            "panel.border" = "#2A3039";
            "terminal.background" = "#111317";
            "terminal.foreground" = "#E7E1D7";
            "terminalCursor.foreground" = "#C6A36A";
            "terminal.selectionBackground" = "#2A303980";
            "button.background" = "#C6A36A";
            "button.foreground" = "#101114";
            "button.hoverBackground" = "#D9B67A";
            "input.background" = "#1D2128";
            "input.foreground" = "#E7E1D7";
            "input.border" = "#2A3039";
            "dropdown.background" = "#1D2128";
            "dropdown.foreground" = "#E7E1D7";
            "dropdown.border" = "#2A3039";
            "list.hoverBackground" = "#252A33";
            "list.activeSelectionBackground" = "#2A3039";
            "list.activeSelectionForeground" = "#F2ECE2";
            "list.highlightForeground" = "#D9B67A";
          };
          "terminal.integrated.minimumContrastRatio" = 1;
        };
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          ms-vscode.cpptools-extension-pack
          vscodevim.vim # Vim emulation
          mads-hartmann.bash-ide-vscode
          tamasfe.even-better-toml
          zainchen.json
          shd101wyy.markdown-preview-enhanced
        ];
      };
    };
  };
}
