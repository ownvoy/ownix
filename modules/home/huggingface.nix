{ config, pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "with-hf";
      text = ''
        set -euo pipefail

        if [ "$#" -eq 0 ]; then
          echo "usage: with-hf <command> [args...]" >&2
          exit 64
        fi

        HF_TOKEN="$(tr -d '\r\n' < "${config.age.secrets."hf-token".path}")"
        export HF_TOKEN
        exec "$@"
      '';
    })
    (pkgs.writeShellApplication {
      name = "hf-copy";
      text = ''
        set -euo pipefail

        secret="$(tr -d '\r\n' < "${config.age.secrets."hf-token".path}")"

        if command -v pbcopy >/dev/null 2>&1; then
          printf '%s' "$secret" | pbcopy
        elif command -v wl-copy >/dev/null 2>&1; then
          printf '%s' "$secret" | wl-copy
        elif command -v xclip >/dev/null 2>&1; then
          printf '%s' "$secret" | xclip -selection clipboard
        elif command -v xsel >/dev/null 2>&1; then
          printf '%s' "$secret" | xsel --clipboard --input
        else
          echo "no clipboard command found (tried pbcopy, wl-copy, xclip, xsel)" >&2
          exit 1
        fi

        echo "Hugging Face token copied to clipboard."
      '';
    })
    (pkgs.writeShellApplication {
      name = "gh-copy";
      text = ''
        set -euo pipefail

        secret="$(tr -d '\r\n' < "${config.age.secrets."gh-token".path}")"

        if command -v pbcopy >/dev/null 2>&1; then
          printf '%s' "$secret" | pbcopy
        elif command -v wl-copy >/dev/null 2>&1; then
          printf '%s' "$secret" | wl-copy
        elif command -v xclip >/dev/null 2>&1; then
          printf '%s' "$secret" | xclip -selection clipboard
        elif command -v xsel >/dev/null 2>&1; then
          printf '%s' "$secret" | xsel --clipboard --input
        else
          echo "no clipboard command found (tried pbcopy, wl-copy, xclip, xsel)" >&2
          exit 1
        fi

        echo "GitHub token copied to clipboard."
      '';
    })
    (pkgs.writeShellApplication {
      name = "openai-copy";
      text = ''
        set -euo pipefail

        secret="$(tr -d '\r\n' < "${config.age.secrets."openai-token".path}")"

        if [ -z "$secret" ]; then
          echo "openai-token secret is empty." >&2
          exit 1
        fi

        if command -v pbcopy >/dev/null 2>&1; then
          printf '%s' "$secret" | pbcopy
        elif command -v wl-copy >/dev/null 2>&1; then
          printf '%s' "$secret" | wl-copy
        elif command -v xclip >/dev/null 2>&1; then
          printf '%s' "$secret" | xclip -selection clipboard
        elif command -v xsel >/dev/null 2>&1; then
          printf '%s' "$secret" | xsel --clipboard --input
        else
          echo "no clipboard command found (tried pbcopy, wl-copy, xclip, xsel)" >&2
          exit 1
        fi

        echo "OpenAI API key copied to clipboard."
      '';
    })
  ];
}
