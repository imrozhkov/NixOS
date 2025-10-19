{ config, pkgs, lib, ... }:

{
  ########################
  # Базовая системная инфа
  ########################
  networking.hostName = "shellbook";
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8";
  ];

  ########################
  # Загрузчик (UEFI)
  ########################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ########################
  # LUKS (root внутри LUKS2→LVM)
  ########################
  # В disko раздел назван "crypt"; это удобно использовать по label:
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/crypt";
    allowDiscards = true;   # TRIM для NVMe
  };

  ##########################################
  # Подкачка: swap-LV (для гибернации) + zram
  ##########################################
  # swap-LV создан disko как /dev/mapper/vg0-swap
  swapDevices = [ { device = "/dev/mapper/vg0-swap"; } ];
  # куда писать образ гибернации
  boot.resumeDevice = "/dev/mapper/vg0-swap";

  # Лёгкая подкачка в RAM (не для гибернации)
  zramSwap = {
    enable = true;
    memoryPercent = 75;  # ~12 ГБ на 16 ГБ RAM
  };

  # Режим sleep→auto-hibernate (как в macOS)
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
  '';


  programs.zsh.enable = true;
  system.stateVersion = "25.05";

  ########################
  # Wayland / Hyprland
  ########################
  services.xserver.enable = false;   # без X11
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;          # полезно для несовместимых приложений
  };

  # Порталы (скриншот/шаринг экрана в Wayland)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  # Аудио/видео стек (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  ########################
  # Сеть, обновления прошивок
  ########################
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.fwupd.enable = true;

  ########################
  # Микрокод Intel, графика
  ########################
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.enable = true;

  ########################
  # Пользователь/шелл
  ########################
  users.users.imrozhkov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
    # чтобы зайти после установки, зададим временный пароль:
    initialPassword = "changeme"; # смените: `passwd imrozhkov`
  };
  users.defaultUserShell = pkgs.zsh;

  ########################
  # Пакеты по-минимуму
  ########################
  environment.systemPackages = with pkgs; [
    git wget curl neovim vim htop ripgrep fd tree
    btrfs-progs lvm2 cryptsetup
    wl-clipboard
    obs-studio
  ];

  ########################
  # Flakes в системе
  ########################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ########################
  # (hardware-configuration.nix будет сгенерирован установщиком)
  ########################
}
