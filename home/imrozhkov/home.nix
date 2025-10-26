{ pkgs, pkgsUnstable, ... }: {
  home.username = "imrozhkov";
  home.homeDirectory = "/home/imrozhkov";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
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
  ] ++ [
    pkgsUnstable.rofi
  ];
}
