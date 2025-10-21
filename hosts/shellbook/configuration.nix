{ config, pkgs, lib, ... }:

{
  ############################################
  # Host / locale / time
  ############################################
  networking.hostName = "shellbook";
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  # Шрифты (кириллица + emoji + JBM Nerd)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

  ############################################
  # Bootloader + LUKS
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS-том, созданный disko (по partlabel)
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/disk-main-crypt";
    allowDiscards = true;
  };

  ############################################
  # Power: suspend-then-hibernate
  ############################################
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitchDocked = "ignore";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
  '';

  ############################################
  # ZRAM + flakes
  ############################################
  zramSwap = {
    enable = true;
    memoryPercent = 75;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################################
  # Wayland / Hyprland (stable из nixpkgs)
  ############################################
  services.xserver.enable = false;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG runtime через PAM (запуск Hyprland из TTY)
  security.pam.services.hyprland = {};

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  ############################################
  # Audio/Video
  ############################################
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  ############################################
  # Firmware / graphics / updates
  ############################################
  # Свежий стек ядра (часто решает проблемы Wi-Fi на новых чипах)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Wi-Fi: прошивки + модуль Intel
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.kernelModules = [ "iwlwifi" ];

  # Графический стек (замена hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # полезно для Steam/Wine
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  services.fwupd.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  ############################################
  # Сеть: NM + wpa_supplicant (надёжно)
  ############################################
  networking.networkmanager = {
    enable = true;
    wifi.backend = "wpa_supplicant";
  };
  # На всякий случай гасим iwd, если был включён где-то ещё
  networking.wireless.iwd.enable = lib.mkForce false;

  networking.firewall.enable = true;

  ############################################
  # SSH: allow from LAN only
  ############################################
  services.openssh = {
    enable = true;
    openFirewall = false; # порт 22 не открыт глобально
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false; # только по ключу
    };
  };
  # Разрешаем 22/tcp только из своей подсети и link-local IPv6
  networking.firewall.extraInputRules = ''
    ip  saddr 192.168.1.0/24 tcp dport 22 accept
    ip6 saddr fe80::/10      tcp dport 22 accept
  '';

  ############################################
  # Users / shell
  ############################################
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.imrozhkov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJd4G7+N8wOlLdpI44TrtgQ4bl8o+oVL5/4YWbw1PxEo imrozhkov@wsl"
    ];
  };

  ############################################
  # Packages
  ############################################
  environment.systemPackages = with pkgs; [
    git wget curl neovim htop tree
    btrfs-progs lvm2 cryptsetup
    obs-studio
    firefox
    kitty
  ];

  # Firefox под Wayland
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  ############################################
  # Misc
  ############################################
  system.stateVersion = "25.05";  # не менять при обновлениях
}
