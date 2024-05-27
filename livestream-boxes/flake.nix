{ # inputs.nixpkgs.url = "nixpkgs/23.11";
  inputs.ajantv2.url = "git+https://git.hacksrus.org/Streams-R-Us/ajantv2-nix.git";
  description = "Setup for 'livestream' boxes in Hacks'R'Us racks";

  outputs = { self, nixpkgs, ajantv2}: {
    nixosConfigurations = {
      streambox-blue = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ajantv2.nixosModules.default
          ({ }: {imports = [./configuration.nix];})
        ];
      };
    };
  };
}
