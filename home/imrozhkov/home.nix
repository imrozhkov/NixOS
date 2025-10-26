{ pkgs, pkgsUnstable, lib, config, ... }:

{
  ##### META #####
  home.username = "imrozhkov";
  home.homeDirectory = "/home/imrozhkov";
  home.stateVersion = "25.05";

  ##### PACKAGES #####
  home.packages =
    (with pkgs; [
      neovim htop tree obs-studio firefox kitty fd bat
      lazygit lazydocker neohtop wlsunset duf jq
      hyprlock hypridle
    ]) ++ [
      pkgsUnstable.rofi
    ];

  ##### SSH (authorized_keys + права) #####
  home.file.".ssh/authorized_keys".text = ''
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJd4G7+N8wOlLdpI44TrtgQ4bl8o+oVL5/4YWbw1PxEo imrozhkov@wsl
'';

  # Создаём ~/.ssh и чиним права уже с корректной группой текущего пользователя
  home.activation.sshPerms = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 -o ${config.home.username} -g "$(id -gn)" "$HOME/.ssh"
    chown ${config.home.username}:"$(id -gn)" "$HOME/.ssh/authorized_keys" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/authorized_keys" 2>/dev/null || true
  '';

  ##### IDLE/LOCK (Hypridle + Hyprlock) #####
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock >/dev/null || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "pidof hyprlock >/dev/null || hyprlock"; }
        {
          timeout = 305;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
