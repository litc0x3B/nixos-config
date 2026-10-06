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
      myConfig = { hostName }: rec {
        # TODO: сделать кастумизируемое им пользователя
        # Вообще это скорее всего можно сделать через опции, а не колхозить свой cfg
        basePath = "/home/litc/Nixos";
        homePath = "home";
        hostHomePath = "hosts/${hostName}/home";
        fullHomePath = "${basePath}/${homePath}";
        fullHostHomePath = "${basePath}/${hostHomePath}";
        inherit hostName;
      };

      shared-modules = [
        ./configuration.nix
        disko.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.litc = import ./home;
          home-manager.backupFileExtension = "backup";

          home-manager.sharedModules = [
            nix-index-database.homeModules.default
            rc-sync.homeManagerModules.default
            { programs.nix-index-database.comma.enable = true; }
          ];
        }
      ];

      mkHost =
        hostName: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              self
              ;
            myConfig = myConfig { inherit hostName; };
          };
          modules = [
            ./hosts/${hostName}
            {
              networking.hostName = hostName;
              home-manager.extraSpecialArgs = {
                inherit inputs self;
                myConfig = myConfig { inherit hostName; };
              };
            }
          ]
          ++ shared-modules;
        };
    in
    {
      nixosConfigurations = {
        litc-nixos-vm = mkHost "litc-nixos-vm" "x86_64-linux";
        litc-nixos-laptop = mkHost "litc-nixos-laptop" "x86_64-linux";
      };
    };
}
