{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "ef00";
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
            type = "8309";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = { allowDiscards = true; };
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
          type = "lvm_lv";
          size = "22G"; 
          content = { type = "swap"; resumeDevice = true; };
        };

        root = {
          type = "lvm_lv";
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "nixos" ];

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
