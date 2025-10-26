{ config, pkgs, lib, ... }:

{
##### HOST/LOCALE/TIME #####
  networking.hostName = "shellbook";
  time.timeZone = "Europe/Moscow";
  services.timesyncd.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

##### BOOT/LUKS #####
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/crypt";
    allowDiscards = true;
  };

##### FIRMWARE/GRAPHICS/UPDATES #####
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

##### NETWORKING #####
  networking.networkmanager = {
    enable = true;
    wifi.backend = "wpa_supplicant";
    dns = "systemd-resolved";
  };
  networking.wireless.iwd.enable = lib.mkForce false;

##### DNS/RESOLVED #####
  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=yes
      LLMNR=yes
    '';
  };

##### FIREWALL #####
  networking.firewall.enable = true;
  networking.firewall.extraInputRules = ''
    ip  saddr 192.168.1.0/24 tcp dport 22 accept
    ip6 saddr fe80::/10      tcp dport 22 accept
  '';

##### SSH #####
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

##### USERS/SHELL #####
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.imrozhkov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    # authorized_keys теперь в Home-Manager
  };

##### WAYLAND/HYPRLAND #####
  services.xserver.enable = false;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

##### XDG PORTALS #####
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

##### LOGIN & LOCK #####
  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        command = "${pkgs.greetd.regreet}/bin/regreet"; # убран GTK_THEME
        user = "greeter";
      };
    };
  };
  security.pam.services.hyprlock = {};
  systemd.user.services.hyprlock-on-sleep = {
  Unit = { Description = "Lock on sleep"; };
  Service = {
    Type = "oneshot";
    ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
  };
  wantedBy = [ "suspend.target" "hibernate.target" "sleep.target" ];
  };

##### AUDIO/VIDEO #####
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

##### POWER #####
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitchDocked = "ignore";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=5min
  '';

##### MEMORY #####
  zramSwap = {
    enable = true;
    memoryPercent = 40;
  };

##### NIX FEATURES #####
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

##### FONTS #####
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

##### PACKAGES #####
  environment.systemPackages = with pkgs; [
    git wget curl
    btrfs-progs lvm2 cryptsetup
  ];

##### ENVIRONMENT #####
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

##### CONTAINERS #####
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/var/lib/docker";
    };
  };

##### MISC #####
  system.stateVersion = "25.05";
}
