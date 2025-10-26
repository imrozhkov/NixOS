{ pkgs, pkgsUnstable, lib, config, ... }:

{
  ##### USER / HOME #####
  home.username = "imrozhkov";
  home.homeDirectory = "/home/imrozhkov";
  home.stateVersion = "25.05";

  ##### PACKAGES #####
  home.packages =
    (with pkgs; [
      neovim
      htop
      tree
      obs-studio
      firefox
      kitty
      fd
      bat
      lazygit
      lazydocker
      neohtop
      wlsunset
      duf
      jq
      hyprlock
      hypridle
    ])
    ++ [
      pkgsUnstable.rofi
    ];

  ##### SSH #####
  home.activation.authorizedKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    u=${config.home.username}
    install -d -m 700 -o "$u" -g "$u" "$HOME/.ssh"
    cat >"$HOME/.ssh/authorized_keys" <<'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJd4G7+N8wOlLdpI44TrtgQ4bl8o+oVL5/4YWbw1PxEo imrozhkov@wsl
EOF
    chown "$u:$u" "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"
  '';

  ##### HYPRIDLE / SCREEN LOCK #####
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd         = "pidof hyprlock >/dev/null || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "pidof hyprlock >/dev/null || hyprlock"; }
        {
          timeout    = 305;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
