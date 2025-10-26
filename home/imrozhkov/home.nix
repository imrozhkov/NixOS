{ pkgs, pkgsUnstable, lib, config, ... }: {
  home.username = "imrozhkov";
  home.homeDirectory = "/home/imrozhkov";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    neovim htop tree obs-studio firefox kitty fd bat
    lazygit lazydocker neohtop wlsunset duf jq
  ] ++ [
    pkgsUnstable.rofi
  ];

  home.activation.initSshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 -o ${config.home.username} -g ${config.home.username} "$HOME/.ssh"
  '';

  home.file.".ssh/authorized_keys" = {
    text = ''
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJd4G7+N8wOlLdpI44TrtgQ4bl8o+oVL5/4YWbw1PxEo imrozhkov@wsl
'';
    mode = "0600";
  };
}
