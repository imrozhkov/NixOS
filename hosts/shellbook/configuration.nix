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

  ############################################
  # Fonts
  ############################################
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

  ############################################
  # Boot / LUKS
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/disk-main-crypt";
    allowDiscards = true;
  };

  ############################################
  # Power
  ############################################
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitchDocked = "ignore";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
  '';

  ############################################
  # Memory / Nix
  ############################################
  zramSwap = {
    enable = true;
    memoryPercent = 75;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################################
  # Wayland / Hyprland
  ############################################
  services.xserver.enable = false;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        command = "env GTK_THEME=Catppuccin-Mocha-Standard-Mauve-Dark ${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
      initial_session = {
        command = "Hyprland";
        user = "imrozhkov";
      };
    };
  };

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
  # Firmware / Graphics / Updates
  ############################################
  boot.kernelPackages = pkgs.linuxPackages_lts;

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.kernelModules = [ "iwlwifi" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  services.fwupd.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  ############################################
  # Networking
  ############################################
  networking.networkmanager = {
    enable = true;
    wifi.backend = "wpa_supplicant";
    dns = "systemd-resolved";
  };
  networking.wireless.iwd.enable = lib.mkForce false;

  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=yes
      LLMNR=yes
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;

  ############################################
  # SSH
  ############################################
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  networking.firewall.extraInputRules = ''
    ip  saddr 192.168.1.0/24 tcp dport 22 accept
    ip6 saddr fe80::/10      tcp dport 22 accept
  '';

  ############################################
  # Users / Shell
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
    catppuccin-gtk
  ];

  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  ############################################
  # Misc
  ############################################
  system.stateVersion = "25.05";
}
