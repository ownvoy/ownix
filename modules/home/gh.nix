{ config, pkgs, ... }:
{
  programs = {
    gh.enable = true;
  };

  systemd.user.services.gh-auth-config = {
    Unit = {
      Description = "Write GitHub CLI auth config from agenix secret";
      After = [ "agenix.service" ];
      Requires = [ "agenix.service" ];
      PartOf = [ "agenix.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "write-gh-auth-config" ''
          set -eu

          gh_config_dir="${config.xdg.configHome}/gh"
          gh_hosts_file="$gh_config_dir/hosts.yml"
          gh_token_file="${config.age.secrets."gh-token".path}"

          mkdir -p "$gh_config_dir"
          chmod 700 "$gh_config_dir"

          {
            printf '%s\n' 'github.com:'
            printf '%s\n' '    user: ${config.home.username}'
            printf '%s' '    oauth_token: '
            cat "$gh_token_file"
            printf '\n'
            printf '%s\n' '    git_protocol: https'
          } > "$gh_hosts_file"

          chmod 600 "$gh_hosts_file"
        ''
      );
    };

    Install.WantedBy = [ "default.target" ];
  };
}
