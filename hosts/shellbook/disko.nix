{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";            # проверьте ваш диск
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "ef00";                 # EFI System Partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          crypt = {
            name = "crypt";
            size = "100%";
            type = "8309";                 # Linux LUKS (можно и 8300, но 8309 точнее)
            content = {
              type = "luks";
              name = "cryptroot";
              passwordFile = "/tmp/luks-pass"; 
              settings = { allowDiscards = true; }; # TRIM для NVMe
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };

    lvm_vg.vg0 = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "22G";                    # для гибернации (16 ГБ RAM + запас)
          content = { type = "swap"; resumeDevice = true; };
        };

        root = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "nixos" ];
            # базовые опции (унаследуются сабвольюмами, если не переопределены)
            mountOptions = [ "compress=zstd:3" "noatime" "ssd" "space_cache=v2" ];
            subvolumes = {
              "@".mountpoint = "/";
              "@home".mountpoint = "/home";
              "@nix".mountpoint = "/nix";
              "@var".mountpoint = "/var";
              "@snapshots".mountpoint = "/.snapshots";

              "@log" = {
                mountpoint = "/var/log";
                mountOptions = [ "compress=zstd:3" "noatime" ];
              };
              "@cache" = {
                mountpoint = "/var/cache";
                mountOptions = [ "compress=no" "noatime" ];
              };
              "@docker" = {
                mountpoint = "/var/lib/docker";
                mountOptions = [ "compress=no" "noatime" ];
              };
              "@containers" = {
                mountpoint = "/var/lib/containers";
                mountOptions = [ "compress=no" "noatime" ];
              };
              "@tmp" = {
                mountpoint = "/tmp";
                mountOptions = [ "noatime" ];
              };
              "@steamlib" = {
                mountpoint = "/var/games/steam";
                mountOptions = [ "compress=no" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
