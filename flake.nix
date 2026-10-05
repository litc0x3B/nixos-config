{
  description = "My NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rc-sync = {
      url = "github:litc0x3B/rc-sync";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-utils = {
      url = "github:lazaroofarrill/niri-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      nix-index-database,
      rc-sync,
      ...
    }@inputs:
    let
      non-hardware-modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit self;
          };
          home-manager.users.litc = import ./home;
          home-manager.backupFileExtension = "backup";

          home-manager.sharedModules = [
            # inputs.sops-nix.homeManagerModules.sops
            # inputs.noctalia.homeModules.default
            nix-index-database.homeModules.default
            rc-sync.homeManagerModules.default
            # optional to also wrap and install comma
            { programs.nix-index-database.comma.enable = true; }
          ];
        }
      ];
    in
    {
      nixosConfigurations.litc-nixos-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          ./hardware-configuration.nix
        ]
        ++ non-hardware-modules;
      };
    };
}
