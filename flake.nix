{
    description  = "NixOS, disko, HM, BTRFS, LUKS2, Hyprland)";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        disko.url = "github:nix-community/disko";
        
        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, disko, home-manager, ... }:
        let
            system = "x86_64-linux";
        in {
            nixosConfigurations.shellbook = nixpkgs.lib.nixosSystem {
                inherit system;

                modules = [
                    disko.nixosModules.disko
                    ./hosts/shellbook/disko.nix
                    ./hosts/shellbook/configuration.nix

                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.extraSpecialArgs = { inherit pkgsUnstable; };
                        home-manager.users.imrozhkov = import ./home/imrozhkov/home.nix;
                    }
                ];
                
                
            };
        };
}
